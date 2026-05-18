import { Tile } from '../models/tile'
import { Result, createSuccess, createError } from '../types/result'
import { ErrorCode, HuType } from '../types/enums'
import { HuJudgeResult } from '../models/results'
import { HandCounts, tilesToCounts } from '../utils/handCounts'
import { substituteAndJudgePingHu, substituteAndJudgePengPengHu, substituteAndJudgeQiDui } from './wildTileSubstitute'

export interface HuCallLimiter {
  maxCalls: number
  callCount: number
}

export function judgeHu(tiles: Tile[]): Result<HuJudgeResult> {
  if (tiles.length === 0) {
    return createError<HuJudgeResult>(ErrorCode.HAND_EMPTY, '手牌不能为空')
  }

  const counts = tilesToCounts(tiles)
  const result = judgeHuByCounts(counts)

  return createSuccess<HuJudgeResult>(result)
}

export function judgeHuByCounts(counts: HandCounts, limiter?: HuCallLimiter): HuJudgeResult {
  const huTypes: HuType[] = []
  let isDegraded = false
  const degradeReasons: string[] = []

  if (substituteAndJudgeQiDui(counts)) {
    huTypes.push(HuType.QI_DUI)
  }

  const pingResult = substituteAndJudgePingHu(counts)
  if (pingResult.isHu) {
    huTypes.push(HuType.PING_HU)
  }
  if (pingResult.isDegraded) {
    isDegraded = true
    degradeReasons.push(pingResult.degradeReason)
  }

  const pengPengResult = substituteAndJudgePengPengHu(counts)
  if (pengPengResult.isHu) {
    huTypes.push(HuType.PENG_PENG_HU)
  }
  if (pengPengResult.isDegraded) {
    isDegraded = true
    degradeReasons.push(pengPengResult.degradeReason)
  }

  if (huTypes.length > 0) {
    return {
      isHu: true,
      huTypes: huTypes,
      shantenNumber: -1,
      isDegraded: isDegraded,
      degradeReason: degradeReasons.join(';')
    }
  }

  return {
    isHu: false,
    huTypes: [],
    shantenNumber: 0,
    isDegraded: isDegraded,
    degradeReason: degradeReasons.join(';')
  }
}

export function isHuByCounts(counts: HandCounts, limiter?: HuCallLimiter): boolean {
  if (limiter !== undefined && limiter.callCount >= limiter.maxCalls) {
    return false
  }

  if (substituteAndJudgeQiDui(counts)) {
    if (limiter !== undefined) {
      limiter.callCount++
    }
    return true
  }

  const pingResult = substituteAndJudgePingHu(counts)
  if (pingResult.isHu) {
    if (limiter !== undefined) {
      limiter.callCount++
    }
    return true
  }

  const pengPengResult = substituteAndJudgePengPengHu(counts)
  if (pengPengResult.isHu) {
    if (limiter !== undefined) {
      limiter.callCount++
    }
    return true
  }

  if (limiter !== undefined) {
    limiter.callCount++
  }
  return false
}
