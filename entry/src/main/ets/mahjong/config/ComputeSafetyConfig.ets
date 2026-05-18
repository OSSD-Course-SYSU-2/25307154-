import { hilog } from '@kit.PerformanceAnalysisKit'

const LOG_DOMAIN = 0xFF00
const LOG_TAG = 'ComputeSafetyConfig'

export const BUDGET_CAP = 10000
export const HU_CALL_LIMIT = 30000
export const SUGGEST_TIMEOUT_MS = 3000
export const MAX_CHECKS_MAP: number[] = [2500, 1500, 800, 300]

export function getMaxChecks(wildCount: number): number {
  if (wildCount < 0) {
    return MAX_CHECKS_MAP[0]
  }
  if (wildCount >= MAX_CHECKS_MAP.length) {
    return MAX_CHECKS_MAP[MAX_CHECKS_MAP.length - 1]
  }
  return MAX_CHECKS_MAP[wildCount]
}

interface ThresholdRange {
  min: number
  max: number
}

const BUDGET_CAP_RANGE: ThresholdRange = { min: 5000, max: 20000 }
const HU_CALL_LIMIT_RANGE: ThresholdRange = { min: 10000, max: 50000 }
const TIMEOUT_MS_RANGE: ThresholdRange = { min: 1000, max: 5000 }
const MAX_CHECKS_RANGES: ThresholdRange[] = [
  { min: 2000, max: 3000 },
  { min: 1000, max: 2000 },
  { min: 500, max: 1000 },
  { min: 200, max: 500 }
]

export function validateSafetyConfig(): void {
  if (BUDGET_CAP < BUDGET_CAP_RANGE.min || BUDGET_CAP > BUDGET_CAP_RANGE.max) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, `BUDGET_CAP=%{public}d超出范围[%{public}d,%{public}d]`, BUDGET_CAP, BUDGET_CAP_RANGE.min, BUDGET_CAP_RANGE.max)
  }
  if (HU_CALL_LIMIT < HU_CALL_LIMIT_RANGE.min || HU_CALL_LIMIT > HU_CALL_LIMIT_RANGE.max) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, `HU_CALL_LIMIT=%{public}d超出范围[%{public}d,%{public}d]`, HU_CALL_LIMIT, HU_CALL_LIMIT_RANGE.min, HU_CALL_LIMIT_RANGE.max)
  }
  if (SUGGEST_TIMEOUT_MS < TIMEOUT_MS_RANGE.min || SUGGEST_TIMEOUT_MS > TIMEOUT_MS_RANGE.max) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, `SUGGEST_TIMEOUT_MS=%{public}d超出范围[%{public}d,%{public}d]`, SUGGEST_TIMEOUT_MS, TIMEOUT_MS_RANGE.min, TIMEOUT_MS_RANGE.max)
  }
  for (let i = 0; i < MAX_CHECKS_MAP.length; i++) {
    const val = MAX_CHECKS_MAP[i]
    const range = MAX_CHECKS_RANGES[i]
    if (val < range.min || val > range.max) {
      hilog.warn(LOG_DOMAIN, LOG_TAG, `MAX_CHECKS_MAP[%{public}d]=%{public}d超出范围[%{public}d,%{public}d]`, i, val, range.min, range.max)
    }
  }
}
