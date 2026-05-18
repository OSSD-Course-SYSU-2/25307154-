import { HandCounts, getTotalCount } from '../utils/handCounts'
import { decodeTileIndex } from '../models/tile'
import { TingItem, TileWall } from '../models/results'
import { isHuByCounts, HuCallLimiter } from '../judge/HuJudge'

export function calculateTingList(counts: HandCounts, wall: TileWall, limiter?: HuCallLimiter): TingItem[] {
  const tingList: TingItem[] = []
  const total = getTotalCount(counts)

  if (total % 3 !== 1) {
    return tingList
  }

  for (let t = 0; t < 28; t++) {
    if (limiter !== undefined && limiter.callCount >= limiter.maxCalls) {
      break
    }
    counts[t] = counts[t] + 1
    const isHu = isHuByCounts(counts, limiter)
    counts[t] = counts[t] - 1

    if (isHu) {
      const tileType = decodeTileIndex(t)
      const remainCount = wall.getRemainCount(t)
      if (remainCount > 0) {
        tingList.push({ tile: tileType, remainCount: remainCount })
      }
    }
  }

  return tingList
}
