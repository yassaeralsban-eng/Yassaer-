# لقيط — منصة إدارة المفقودات والمعثورات

تطبيق جوال (Flutter) باللغة العربية مع دعم RTL لإدارة دورة استعادة المفقودات
والمعثورات في مدينة عتق — محافظة شبوة، وفق وثائق SRS / SAD / UX-UI v1.0.

## المعمارية (SAD)

تقسيم الطبقات:

```
lib/
├── main.dart                     # نقطة الدخول + تهيئة Firebase / الوضع التجريبي
└── src/
    ├── domain/                   # لا تعتمد على أي إطار خارجي
    │   ├── entities/             # الكيانات + حالات دورة حياة البلاغ
    │   ├── services/             # MatchingService (معادلة SAD 12) قابلة للاختبار
    │   ├── repositories/         # عقود المستودعات (Repository Pattern)
    │   └── use_cases/            # قواعد الأعمال (CreateReport, Search, Recovery...)
    ├── data/
    │   ├── models/               # نماذج Firestore (toMap/fromMap)
    │   ├── repositories/         # تطبيقات Firebase + تطبيقات تجريبية في الذاكرة
    │   └── demo_data.dart        # بيانات أولية للعرض والاختبار
    ├── application/              # طبقة التطبيق: مزودات Riverpod
    └── presentation/
        ├── theme/                # Design Tokens حسب مواصفات UX/UI (القسم 24)
        ├── screens/              # الشاشات الرئيسية الخمس
        └── widgets/              # مكونات مشتركة (ReportCard, StatusPill)
```

- **إدارة الحالة:** Riverpod (`flutter_riverpod`).
- **قاعدة البيانات:** Cloud Firestore مع فصل `private_verification` عن
  `reports` (Privacy by Design).
- **الخدمات الخلفية:** Cloud Functions في `functions/` (المطابقة، التحقق،
  الإشعارات، التدقيق).
- **القواعد الأمنية:** `firestore.rules` و `storage.rules` و
  `firestore.indexes.json` مع فهارس مركّبة وفق الاستعلامات الفعلية.

## الوضع التجريبي

عند الإقلاع يحاول التطبيق تهيئة Firebase (مشروع `found-39d5d` عبر
`firebase_options.dart`). إذا تعذّر الاتصال، يعود تلقائياً إلى مستودعات
داخل الذاكرة (`demo_repositories.dart`) مع بيانات تجريبية حتى يبقى التطبيق
قابلاً للاستخدام والاختبار دون اتصال.

## خوارزمية المطابقة (SAD 12)

```
MatchScore = 0.20×CatMatch + 0.20×LocMatch + 0.15×DateMatch
           + 0.10×ColorMatch + 0.35×DescSimilarity
```

المطابقة قابلة للتفسير عبر `factors`، ولا تعتبر إثباتاً للملكية (SAD 13).

## دورة حياة البلاغ (SAD 11)

`OPEN → MATCHED → CLAIMED → VERIFYING → APPROVED/REJECTED/REVIEW
→ HANDOVER_PENDING → RECOVERED → CLOSED`

## التشغيل والاختبار

```bash
flutter pub get
flutter run                       # التشغيل
flutter test                      # 16 اختباراً (وحدة + Widget)
flutter analyze                   # تحليل ثابت
flutter build web                 # بناء الإصدار
```

لقواعد Firebase محلياً:

```bash
firebase emulators:start
```

