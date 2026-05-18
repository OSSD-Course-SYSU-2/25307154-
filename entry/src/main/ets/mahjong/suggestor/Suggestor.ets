import { Tile } from '../models/tile'
import { Result, createSuccess, createError } from '../types/result'
import { ErrorCode, RiskTag } from '../types/enums'
import { SuggestResult, SuggestionItem, TileWall } from '../models/results'
import { TileType, decodeTileIndex } from '../models/tile'
import { tilesToCounts } from '../utils/handCounts'
import { calculateShanten, calculateShantenPrecise } from '../analyzer/shantenCalculator'
import { calculateTingList } from '../analyzer/tingCalculator'
import { calculateEffectiveDraws } from '../analyzer/effectiveDrawCalculator'
import { judgeHuByCounts, HuCallLimiter } from '../judge/HuJudge'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { HU_CALL_LIMIT, SUGGEST_TIMEOUT_MS } from '../config/ComputeSafetyConfig'

const LOG_DOMAIN = 0xFF00
const LOG_TAG = 'Suggestor'

export function suggestDiscard(tiles: Tile[], wall: TileWall): Result<SuggestResult> {
  const counts = tilesToCounts(tiles)
  const limiter: HuCallLimiter = { maxCalls: HU_CALL_LIMIT, callCount: 0 }
  const startTime: number = Date.now()
  const timeoutMs: number = SUGGEST_TIMEOUT_MS

  const huResult = judgeHuByCounts(counts, limiter)
  if (huResult.isHu) {
    return createError<SuggestResult>(ErrorCode.ALREADY_HU, '当前已胡牌，无需打牌建议')
  }

  const currentShanten = calculateShantenPrecise(counts, limiter)

  const rawSuggestions: RawSuggestion[] = []
  const processed = new Set<number>()

  let totalCount = 0
  for (let t = 0; t < 28; t++) {
    if (counts[t] > 0) {
      totalCount++
    }
  }

  let completedCount = 0
  let isDegraded = false
  const degradeReasons: string[] = []

  for (let t = 0; t < 28; t++) {
    if (counts[t] > 0 && !processed.has(t)) {
      processed.add(t)

      if (limiter.callCount >= limiter.maxCalls) {
        isDegraded = true
        degradeReasons.push('调用次数超限')
        break
      }

      const elapsedMs = Date.now() - startTime
      if (elapsedMs > timeoutMs) {
        isDegraded = true
        degradeReasons.push('计算超时')
        hilog.warn(LOG_DOMAIN, LOG_TAG, `计算超时降级: elapsedMs=%{public}d, timeoutMs=%{public}d, completedCount=%{public}d, totalCount=%{public}d`, elapsedMs, timeoutMs, completedCount, totalCount)
        break
      }

      counts[t] = counts[t] - 1
      const afterShanten = calculateShantenPrecise(counts, limiter)

      let effectiveDrawCount = 0
      const drawTileTypes: TileType[] = []

      if (afterShanten === 0) {
        const tingList = calculateTingList(counts, wall, limiter)
        for (let i = 0; i < tingList.length; i++) {
          effectiveDrawCount += tingList[i].remainCount
          drawTileTypes.push(tingList[i].tile)
        }
      } else if (afterShanten > 0 && afterShanten <= 2) {
        const draws = calculateEffectiveDraws(counts, wall, afterShanten, limiter)
        for (let i = 0; i < draws.length; i++) {
          effectiveDrawCount += draws[i].remainCount
          drawTileTypes.push(draws[i].tile)
        }
      }

      counts[t] = counts[t] + 1

      rawSuggestions.push({
        tileIndex: t,
        tileType: decodeTileIndex(t),
        shantenAfterDiscard: afterShanten,
        effectiveDrawCount: effectiveDrawCount,
        drawTiles: drawTileTypes,
        isWild: t === 27
      })

      completedCount++
    }
  }

  if (isDegraded) {
    hilog.warn(LOG_DOMAIN, LOG_TAG, `胡牌判定调用超限: callCount=%{public}d, maxCalls=%{public}d, completedCount=%{public}d, totalCount=%{public}d`, limiter.callCount, limiter.maxCalls, completedCount, totalCount)
  }

  rawSuggestions.sort((a, b) => {
    if (a.shantenAfterDiscard !== b.shantenAfterDiscard) {
      return a.shantenAfterDiscard - b.shantenAfterDiscard
    }
    return b.effectiveDrawCount - a.effectiveDrawCount
  })

  const mergedSuggestions: SuggestionItem[] = []
  for (let i = 0; i < rawSuggestions.length; i++) {
    const raw = rawSuggestions[i]
    let existingIndex = -1
    for (let j = 0; j < mergedSuggestions.length; j++) {
      if (mergedSuggestions[j].shantenAfterDiscard === raw.shantenAfterDiscard &&
          mergedSuggestions[j].effectiveDrawCount === raw.effectiveDrawCount) {
        existingIndex = j
        break
      }
    }

    if (existingIndex >= 0) {
      mergedSuggestions[existingIndex].discardTiles.push(raw.tileType)
      if (raw.isWild) {
        mergedSuggestions[existingIndex].riskTag = RiskTag.WILD_TILE_RISK
      }
    } else {
      const discardTiles: TileType[] = [raw.tileType]
      mergedSuggestions.push({
        discardTiles: discardTiles,
        shantenAfterDiscard: raw.shantenAfterDiscard,
        effectiveDrawCount: raw.effectiveDrawCount,
        drawTiles: raw.drawTiles,
        riskTag: raw.isWild ? RiskTag.WILD_TILE_RISK : RiskTag.NONE
      })
    }
  }

  return createSuccess<SuggestResult>({
    suggestions: mergedSuggestions,
    isComplete: completedCount === totalCount,
    completedCount: completedCount,
    totalCount: totalCount,
    isDegraded: isDegraded,
    degradeReason: degradeReasons.join(';')
  })
}

interface RawSuggestion {
  tileIndex: number
  tileType: TileType
  shantenAfterDiscard: number
  effectiveDrawCount: number
  drawTiles: TileType[]
  isWild: boolean
}
