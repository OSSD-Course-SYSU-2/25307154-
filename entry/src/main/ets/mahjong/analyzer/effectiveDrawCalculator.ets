import { HandCounts } from '../utils/handCounts'
import { decodeTileIndex } from '../models/tile'
import { DrawItem, TileWall } from '../models/results'
import { isHuByCounts, HuCallLimiter } from '../judge/HuJudge'

export function calculateEffectiveDraws(counts: HandCounts, wall: TileWall, shanten: number, limiter?: HuCallLimiter): DrawItem[] {
  const draws: DrawItem[] = []

  if (shanten <= 0) {
    return draws
  }

  if (shanten === 1) {
    for (let t = 0; t < 28; t++) {
      if (limiter !== undefined && limiter.callCount >= limiter.maxCalls) {
        break
      }
      const remainCount = wall.getRemainCount(t)
      if (remainCount <= 0) {
        continue
      }

      counts[t] = counts[t] + 1
      const ting = checkTingInPlace(counts, limiter)
      counts[t] = counts[t] - 1

      if (ting) {
        const tileType = decodeTileIndex(t)
        draws.push({ tile: tileType, remainCount: remainCount })
      }
    }
    return draws
  }

  for (let t = 0; t < 28; t++) {
    const remainCount = wall.getRemainCount(t)
    if (remainCount <= 0) {
      continue
    }

    if (t === 27) {
      const tileType = decodeTileIndex(t)
      draws.push({ tile: tileType, remainCount: remainCount })
      continue
    }

    const newShanten = estimateAfterAdd(counts, t, shanten)
    if (newShanten < shanten) {
      const tileType = decodeTileIndex(t)
      draws.push({ tile: tileType, remainCount: remainCount })
    }
  }

  return draws
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

function estimateAfterAdd(counts: HandCounts, tileIdx: number, currentShanten: number): number {
  counts[tileIdx] = counts[tileIdx] + 1
  const newShanten = quickEstimateShanten(counts)
  counts[tileIdx] = counts[tileIdx] - 1
  return newShanten
}

function quickEstimateShanten(counts: HandCounts): number {
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
  if (shanten < 0) {
    shanten = 0
  }
  if (shanten > 7) {
    shanten = 7
  }
  return shanten
}
