import { HandCounts } from '../utils/handCounts'
import { isHuByCounts, HuCallLimiter } from '../judge/HuJudge'
import { getMaxChecks } from '../config/ComputeSafetyConfig'

function getAdaptiveMaxChecks(wildCount: number): number {
  return getMaxChecks(wildCount)
}

export function calculateShanten(counts: HandCounts, limiter?: HuCallLimiter): number {
  if (isHuByCounts(counts, limiter)) {
    return -1
  }

  if (checkTingInPlace(counts, limiter)) {
    return 0
  }

  return estimateShanten(counts)
}

export function calculateShantenPrecise(counts: HandCounts, limiter?: HuCallLimiter): number {
  if (isHuByCounts(counts, limiter)) {
    return -1
  }

  if (checkTingInPlace(counts, limiter)) {
    return 0
  }

  const wildCount = counts[27]
  const maxChecks = getAdaptiveMaxChecks(wildCount)

  if (checkShantenOneWithLimit(counts, maxChecks, limiter)) {
    return 1
  }

  return estimateShanten(counts)
}

function checkTingInPlace(counts: HandCounts, limiter?: HuCallLimiter): boolean {
  for (let t = 0; t < 28; t++) {
    if (limiter !== undefined && limiter.callCount >= limiter.maxCalls) {
      return false
    }
    counts[t] = counts[t] + 1
    const hu = isHuByCounts(counts, limiter)
    counts[t] = counts[t] - 1
    if (hu) {
      return true
    }
  }
  return false
}

function checkShantenOneWithLimit(counts: HandCounts, maxChecks: number, limiter?: HuCallLimiter): boolean {
  let checks = 0
  for (let d = 0; d < 28; d++) {
    if (counts[d] <= 0) {
      continue
    }
    counts[d] = counts[d] - 1

    for (let p = 0; p < 28; p++) {
      if (limiter !== undefined && limiter.callCount >= limiter.maxCalls) {
        counts[d] = counts[d] + 1
        return false
      }
      if (p === d) {
        continue
      }
      if (counts[p] >= 4) {
        continue
      }
      counts[p] = counts[p] + 1

      for (let t = 0; t < 28; t++) {
        if (limiter !== undefined && limiter.callCount >= limiter.maxCalls) {
          counts[p] = counts[p] - 1
          counts[d] = counts[d] + 1
          return false
        }
        counts[t] = counts[t] + 1
        checks++
        if (isHuByCounts(counts, limiter)) {
          counts[t] = counts[t] - 1
          counts[p] = counts[p] - 1
          counts[d] = counts[d] + 1
          return true
        }
        counts[t] = counts[t] - 1

        if (checks >= maxChecks) {
          counts[p] = counts[p] - 1
          counts[d] = counts[d] + 1
          return false
        }
      }

      counts[p] = counts[p] - 1
    }

    counts[d] = counts[d] + 1
  }
  return false
}

function estimateShanten(counts: HandCounts): number {
  let melds = 0
  let pairs = 0
  const tmp: number[] = []
  for (let i = 0; i < 28; i++) {
    tmp.push(counts[i])
  }

  for (let i = 0; i < 28; i++) {
    while (tmp[i] >= 3) {
      tmp[i] -= 3
      melds++
    }
    if (tmp[i] >= 2) {
      tmp[i] -= 2
      pairs++
    }
  }

  for (let s = 0; s < 3; s++) {
    const base = s * 9
    for (let i = 0; i < 7; i++) {
      const idx = base + i
      if (tmp[idx] >= 1 && tmp[idx + 1] >= 1 && tmp[idx + 2] >= 1) {
        tmp[idx] -= 1
        tmp[idx + 1] -= 1
        tmp[idx + 2] -= 1
        melds++
      }
    }
  }

  let shanten = 4 - melds - pairs
  if (pairs > 1) {
    shanten += (pairs - 1)
  }
  if (shanten < 2) {
    shanten = 2
  }
  if (shanten > 7) {
    shanten = 7
  }
  return shanten
}
