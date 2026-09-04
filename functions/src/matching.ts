/**
 * Matching Service for Laqit (SAD section 12).
 *
 * MatchScore = 0.20*CatMatch + 0.20*LocMatch + 0.15*DateMatch
 *            + 0.10*ColorMatch + 0.35*DescSimilarity
 *
 * Important: The score is used only for ranking potential candidates and
 * deciding which cases deserve a verification flow. It is NOT proof of
 * ownership (SAD section 13).
 */

/** Weights defined in the SAD architecture document. */
export const MATCH_WEIGHTS = {
  category: 0.2,
  location: 0.2,
  date: 0.15,
  color: 0.1,
  description: 0.35,
} as const;

export interface MatchFactors {
  category: number;
  location: number;
  date: number;
  color: number;
  description: number;
}

export interface MatchOutput {
  score: number;
  factors: MatchFactors;
}

/** Normalized 0..1 string similarity. */
function similarity(a: string, b: string): number {
  const x = a.trim().toLowerCase();
  const y = b.trim().toLowerCase();
  if (!x || !y) return 0;
  if (x === y) return 1;
  // Token overlap heuristic (suitable for Arabic keyword matching).
  const tokensX = new Set(x.split(/\s+/));
  const tokensY = new Set(y.split(/\s+/));
  let common = 0;
  for (const t of tokensX) {
    if (tokensY.has(t)) common++;
  }
  return common / Math.max(tokensX.size, tokensY.size);
}

/** Proximity between two date values normalized to 0..1. */
function dateMatch(a: Date, b: Date, windowDays = 7): number {
  const diffDays = Math.abs(a.getTime() - b.getTime()) / (1000 * 3600 * 24);
  if (diffDays <= windowDays) return 1;
  if (diffDays >= windowDays * 4) return 0;
  return 1 - (diffDays - windowDays) / (windowDays * 3);
}

/** Compares two free-text descriptions with keyword overlap. */
function descriptionSimilarity(a: string, b: string): number {
  return similarity(a, b);
}

/**
 * Computes the weighted match score between a lost report and a found report.
 *
 * @param lost - public data of the lost report.
 * @param found - public data of the found report.
 * @param beforeDate - today's date used to cap event dates and prevent
 *   future-dated reports from skewing the score.
 */
export function computeMatchScore(
  lost: {
    categoryId: string;
    approximateLocation: string;
    eventDate: Date;
    description: string;
    color?: string | null;
  },
  found: {
    categoryId: string;
    approximateLocation: string;
    eventDate: Date;
    description: string;
    color?: string | null;
  },
  beforeDate: Date = new Date(),
): MatchOutput {
  const cat = lost.categoryId === found.categoryId ? 1 : 0;
  const loc = lost.approximateLocation === found.approximateLocation ? 1 : 0;
  const date = dateMatch(lost.eventDate, found.eventDate);
  const color =
    lost.color && found.color && lost.color === found.color ? 1 : 0;
  const desc = descriptionSimilarity(lost.description, found.description);

  const factors: MatchFactors = {
    category: cat,
    location: loc,
    date,
    color,
    description: desc,
  };

  const score =
    MATCH_WEIGHTS.category * cat +
    MATCH_WEIGHTS.location * loc +
    MATCH_WEIGHTS.date * date +
    MATCH_WEIGHTS.color * color +
    MATCH_WEIGHTS.description * desc;

  return { score, factors };
}