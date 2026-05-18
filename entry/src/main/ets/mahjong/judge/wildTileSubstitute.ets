import { HandCounts, cloneHandCounts } from '../utils/handCounts'
import { judgePingHu } from './pingHu'
import { judgeQiDui } from './qiDui'
import { judgePengPengHu } from './pengPengHu'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BUDGET_CAP } from '../config/ComputeSafetyConfig'

const LOG_DOMAIN = 0xFF00
const LOG_TAG = 'WildTileSubstitute'

export interface ComputeBudget {
  maxSteps: number
  usedSteps: number
  isExceeded: boolean
}

export interface SubstituteResult {
  isHu: boolean
  isDegraded: boolean
  degradeReason: string
}

export function createComputeBudget(wildCount: number): ComputeBudget {
  let maxSteps = 1
  for (let i = 0; i < wildCount; i++) {
    maxSteps *= 27
  }
  if (maxSteps > BUDGET_CAP) {
    maxSteps = BUDGET_CAP
  }
  return { maxSteps, usedSteps: 0, isExceeded: false }
}

export function substituteAndJudgePingHu(counts: HandCounts): SubstituteResult {
  const wildCount = counts[27]
  if (wildCount === 0) {
    return { isHu: judgePingHu(counts), isDegraded: false, degradeReason: '' }
  }

  const baseCounts = cloneHandCounts(counts)
  baseCounts[27] = 0

  const budget = createComputeBudget(wildCount)
  const result = trySubstitutions(baseCounts, wildCount, 0, judgePingHu, budget)

  if (result.isDegraded) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, `计算步骤超限: wildCount=%{public}d, usedSteps=%{public}d, maxSteps=%{public}d`, wildCount, budget.usedSteps, budget.maxSteps)
  }

  return result
}

export function substituteAndJudgePengPengHu(counts: HandCounts): SubstituteResult {
  const wildCount = counts[27]
  if (wildCount === 0) {
    return { isHu: judgePengPengHu(counts), isDegraded: false, degradeReason: '' }
  }

  const baseCounts = cloneHandCounts(counts)
  baseCounts[27] = 0

  const budget = createComputeBudget(wildCount)
  const result = trySubstitutions(baseCounts, wildCount, 0, judgePengPengHu, budget)

  if (result.isDegraded) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, `计算步骤超限: wildCount=%{public}d, usedSteps=%{public}d, maxSteps=%{public}d`, wildCount, budget.usedSteps, budget.maxSteps)
  }

  return result
}

type JudgeFn = (counts: HandCounts) => boolean

function trySubstitutions(baseCounts: HandCounts, remaining: number, startIdx: number, judgeFn: JudgeFn, budget: ComputeBudget): SubstituteResult {
  if (remaining > 4) {
    return { isHu: false, isDegraded: true, degradeReason: '递归深度异常' }
  }

  if (budget.isExceeded) {
    return { isHu: false, isDegraded: true, degradeReason: '计算步骤超限' }
  }

  if (remaining === 0) {
    const result = judgeFn(baseCounts)
    budget.usedSteps++
    if (budget.usedSteps >= budget.maxSteps) {
      budget.isExceeded = true
    }
    return { isHu: result, isDegraded: false, degradeReason: '' }
  }

  for (let i = startIdx; i < 27; i++) {
    if (baseCounts[i] >= 4) {
      continue
    }

    if (budget.isExceeded) {
      break
    }

    const newCounts = cloneHandCounts(baseCounts)
    newCounts[i] = newCounts[i] + 1

    const subResult = trySubstitutions(newCounts, remaining - 1, i, judgeFn, budget)

    if (subResult.isHu) {
      return subResult
    }
  }

  if (budget.isExceeded) {
    return { isHu: false, isDegraded: true, degradeReason: '计算步骤超限' }
  }
  return { isHu: false, isDegraded: false, degradeReason: '' }
}

export function substituteAndJudgeQiDui(counts: HandCounts): boolean {
  return judgeQiDui(counts)
}
