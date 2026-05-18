import { TingItem, DrawItem, TileWall } from '../models/results'

export function calculateHuProbability(
  tingList: TingItem[],
  effectiveDraws: DrawItem[],
  wall: TileWall,
  shanten: number
): number {
  const totalRemaining = wall.totalRemaining
  if (totalRemaining === 0) {
    return 0
  }

  if (shanten === 0) {
    let totalRemain = 0
    for (const item of tingList) {
      totalRemain += item.remainCount
    }
    return roundTo4(totalRemain / totalRemaining)
  }

  if (shanten > 0) {
    let totalRemain = 0
    for (const item of effectiveDraws) {
      totalRemain += item.remainCount
    }
    return roundTo4(totalRemain / totalRemaining)
  }

  return 1.0
}

function roundTo4(value: number): number {
  return Math.round(value * 10000) / 10000
}
