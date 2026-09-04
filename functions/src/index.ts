/**
 * Cloud Functions for Laqit (SAD section 18).
 *
 * | Function             | Trigger                            | Responsibility                                |
 * |----------------------|------------------------------------|-----------------------------------------------|
 * | onReportCreated      | reports/{id} create                | Candidate retrieval + match score + notify    |
 * | onMatchFound         | match_candidates/{id} create       | Log event + send appropriate notification     |
 * | onRecoveryCreated    | recovery_requests/{id} create      | Notify parties                                |
 * | verifyAnswers        | HTTPS Callable                      | Verify answers and return result              |
 * | onRecoveryUpdate     | recovery_requests/{id} update      | State transitions + notifications + audit     |
 * | onHandoverCreated    | handover_records/{id} create       | Handover event + notify parties               |
 */

import * as admin from "firebase-admin";
import * as functions from "firebase-functions";
import { computeMatchScore } from "./matching";

admin.initializeApp();

const db = admin.firestore();

/** Operational threshold for sending a "potential match" notification.
 *  This is a calibratable parameter, NOT a claim of statistical accuracy
 *  (SAD section 13). */
const MATCH_THRESHOLD = 0.6;

/** Writes an audit log entry (SAD section 10). */
async function audit(
  actorId: string,
  action: string,
  entityType: string,
  entityId: string,
  metadata: Record<string, unknown> = {},
) {
  await db.collection("audit_logs").add({
    actorId,
    action,
    entityType,
    entityId,
    metadata,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

interface ReportDoc {
  ownerId: string;
  reportType: string;
  categoryId: string;
  title: string;
  description: string;
  color?: string | null;
  approximateLocation: string;
  eventDate: admin.firestore.Timestamp;
  status: string;
  [key: string]: unknown;
}

/** onReportCreated: run candidate retrieval and matching. */
export const onReportCreated = functions.firestore
  .document("reports/{reportId}")
  .onCreate(
    async (
      snap: FirebaseFirestore.DocumentSnapshot,
      context: functions.EventContext,
    ) => {
      const report = snap.data() as ReportDoc;
      const reportId = context.params.reportId as string;

    // A lost report is scanned against existing found reports and vice versa.
    const otherType = report.reportType === "lost" ? "found" : "lost";
    const candidates = await db
      .collection("reports")
      .where("reportType", "==", otherType)
      .where("status", "==", "open")
      .limit(20)
      .get();

    const today = new Date();
    const scored: {
      docId: string;
      score: number;
      result: ReturnType<typeof computeMatchScore>;
    }[] = [];

    for (const doc of candidates.docs) {
      const other = doc.data() as ReportDoc;
      if (other.ownerId === report.ownerId) continue;

      const lost =
        report.reportType === "lost"
          ? {
              categoryId: report.categoryId,
              approximateLocation: report.approximateLocation,
              eventDate: report.eventDate.toDate(),
              description: report.description,
              color: report.color,
            }
          : {
              categoryId: other.categoryId,
              approximateLocation: other.approximateLocation,
              eventDate: other.eventDate.toDate(),
              description: other.description,
              color: other.color,
            };

      const found =
        report.reportType === "found"
          ? {
              categoryId: report.categoryId,
              approximateLocation: report.approximateLocation,
              eventDate: report.eventDate.toDate(),
              description: report.description,
              color: report.color,
            }
          : {
              categoryId: other.categoryId,
              approximateLocation: other.approximateLocation,
              eventDate: other.eventDate.toDate(),
              description: other.description,
              color: other.color,
            };

      const result = computeMatchScore(lost, found, today);
      scored.push({ docId: doc.id, score: result.score, result });
    }

    scored.sort((a, b) => b.score - a.score);
    const above = scored.filter((s) => s.score >= MATCH_THRESHOLD);

    await audit(report.ownerId, "report_created", "reports", reportId, {
      candidatesConsidered: scored.length,
      matchesFound: above.length,
    });

    if (above.length === 0) return;

    // Persist each qualifying match candidate (SAD section 12 explains factors).
    const batch = db.batch();
    for (const m of above.slice(0, 5)) {
      const matchId =
        report.reportType === "lost"
          ? `${reportId}_${m.docId}`
          : `${m.docId}_${reportId}`;
      const ref = db.collection("match_candidates").doc(matchId);
      batch.set(ref, {
        lostReportId: report.reportType === "lost" ? reportId : m.docId,
        foundReportId: report.reportType === "found" ? reportId : m.docId,
        score: m.score,
        factors: m.result.factors,
        status: "pending",
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Notify the owner of the other report (SAD section 19 - MATCH_FOUND).
      const otherDoc = candidates.docs.find(
        (d: admin.firestore.QueryDocumentSnapshot) => d.id === m.docId,
      );
      if (otherDoc) {
        const other = otherDoc.data() as ReportDoc;
        await db.collection("notifications").add({
          userId: other.ownerId,
          type: "matchFound",
          title: "تطابق محتمل جديد",
          body: "وجدنا بلاغًا قد يتشابه مع بلاغك.",
          entityId: matchId,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
      }
    }
    await batch.commit();
  });

/** verifyAnswers: HTTPS Callable verifying user answers (SAD section 14). */
export const verifyAnswers = functions.https.onCall(
  async (req: functions.https.CallableRequest<{
    recoveryRequestId: string;
    answers: string[];
  }>) => {
    const caller = req.auth?.uid;
    if (!caller) {
      throw new functions.https.HttpsError("unauthenticated", "يجب تسجيل الدخول أولاً");
    }

    const { recoveryRequestId, answers } = req.data;
    if (!recoveryRequestId || !Array.isArray(answers)) {
      throw new functions.https.HttpsError("invalid-argument", "بيانات الطلب غير صحيحة");
    }

    const requestSnap = await db
      .collection("recovery_requests")
      .doc(recoveryRequestId)
      .get();
    if (!requestSnap.exists) {
      throw new functions.https.HttpsError("not-found", "الطلب غير موجود");
    }
    const request = requestSnap.data()!;
    if (request.requesterId !== caller) {
      throw new functions.https.HttpsError("permission-denied", "لا تملك صلاحية");
    }

    const matchSnap = await db
      .collection("match_candidates")
      .doc(request.matchId)
      .get();
    if (!matchSnap.exists) {
      throw new functions.https.HttpsError("not-found", "التطابق غير موجود");
    }
    const match = matchSnap.data()!;

    // Secret answers are stored on private_verification of the found report.
    const privateSnap = await db
      .collection("private_verification")
      .doc(match.foundReportId)
      .get();
    if (!privateSnap.exists) {
      throw new functions.https.HttpsError("failed-precondition", "لا توجد بيانات تحقق");
    }
    const privateData = privateSnap.data()!;
    const expectedAnswers: string[] = privateData.verificationAnswers ?? [];

    let result: "VERIFIED" | "UNCERTAIN" | "UNVERIFIED";
    if (expectedAnswers.length === 0) {
      result = "UNCERTAIN";
    } else {
      const normal = (s: string) => s.trim().toLowerCase();
      let correct = 0;
      for (let i = 0; i < Math.min(answers.length, expectedAnswers.length); i++) {
        if (normal(answers[i]) === normal(expectedAnswers[i])) correct++;
      }
      const ratio = correct / expectedAnswers.length;
      if (ratio >= 0.66) result = "VERIFIED";
      else if (ratio >= 0.33) result = "UNCERTAIN";
      else result = "UNVERIFIED";
    }

    const status =
      result === "VERIFIED"
        ? "APPROVED"
        : result === "UNCERTAIN"
          ? "REVIEW"
          : "REJECTED";

    await requestSnap.ref.update({
      status,
      verificationResult: result,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    await audit(caller, "verify_answers", "recovery_requests", recoveryRequestId, { result });

    return { result, status };
  },
);