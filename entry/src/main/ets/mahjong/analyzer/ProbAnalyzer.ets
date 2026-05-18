import { Tile } from '../models/tile'
import { Result, createSuccess } from '../types/result'
import { ProbabilityResult, TingItem, DrawItem, TileWall } from '../models/results'
import { HandCounts, tilesToCounts, getTotalCount } from '../utils/handCounts'
import { getRuleConfig } from '../config/RuleConfig'
import { calculateShanten } from './shantenCalculator'
import { calculateTingList } from './tingCalculator'
import { calculateEffectiveDraws } from './effectiveDrawCalculator'
import { calculateHuProbability } from './probabilityCalculator'

export function analyzeProbability(tiles: Tile[], wall: TileWall): Result<ProbabilityResult> {
  const counts = tilesToCounts(tiles)

  const shanten = calculateShanten(counts)

  let tingList: TingItem[] = []
  let effectiveDraws: DrawItem[] = []

  if (shanten === 0) {
    tingList = calculateTingList(counts, wall)
  } else if (shanten > 0 && shanten <= 2) {
    effectiveDraws = calculateEffectiveDraws(counts, wall, shanten)
  }

  const huProbability = calculateHuProbability(tingList, effectiveDraws, wall, shanten)

  const result: ProbabilityResult = {
    shantenNumber: shanten,
    tingList: tingList,
    effectiveDraws: effectiveDraws,
    huProbability: huProbability
  }

  return createSuccess<ProbabilityResult>(result)
}

export function analyzeProbabilityByCounts(counts: HandCounts, wall: TileWall): ProbabilityResult {
  const shanten = calculateShanten(counts)

  let tingList: TingItem[] = []
  let effectiveDraws: DrawItem[] = []

  if (shanten === 0) {
    tingList = calculateTingList(counts, wall)
  } else if (shanten > 0 && shanten <= 2) {
    effectiveDraws = calculateEffectiveDraws(counts, wall, shanten)
  }

  const huProbability = calculateHuProbability(tingList, effectiveDraws, wall, shanten)

  return {
    shantenNumber: shanten,
    tingList: tingList,
    effectiveDraws: effectiveDraws,
    huProbability: huProbability
  }
}
