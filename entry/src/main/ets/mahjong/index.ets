export { TileSuit, HuType, RiskTag, ErrorCode } from './types/enums'
export type { TileFaceValue } from './types/enums'
export { createSuccess, createError } from './types/result'
export type { Result } from './types/result'

export type { TileType, Tile } from './models/tile'
export { encodeTileIndex, encodeTileIndexFromTile, decodeTileIndex, tileTypeToString, tileTypeEquals, tileToTileType } from './models/tile'

export type { HuJudgeResult, TingItem, DrawItem, ProbabilityResult, SuggestionItem, SuggestResult, HandInfo, DrawResult, DiscardResult, TileWall } from './models/results'

export { tilesToCounts, countsToTileTypes, encodeHandCounts, getTotalCount, getWildCount, createEmptyHandCounts, cloneHandCounts } from './utils/handCounts'
export type { HandCounts } from './utils/handCounts'

export { getRuleConfig, setWildTile, resetRuleConfig } from './config/RuleConfig'
export type { RuleConfig, FaceValueRange } from './config/RuleConfig'

export { TilePool } from './generator/TilePool'
export { TileWallImpl } from './generator/TileWall'
export { TileGenerator } from './generator/TileGenerator'

export { judgeHu, judgeHuByCounts, isHuByCounts } from './judge/HuJudge'
export type { HuCallLimiter } from './judge/HuJudge'
export { judgePingHu } from './judge/pingHu'
export { judgeQiDui } from './judge/qiDui'
export { judgePengPengHu } from './judge/pengPengHu'

export { calculateShanten, calculateShantenPrecise } from './analyzer/shantenCalculator'
export { calculateTingList } from './analyzer/tingCalculator'
export { calculateEffectiveDraws } from './analyzer/effectiveDrawCalculator'
export { calculateHuProbability } from './analyzer/probabilityCalculator'
export { analyzeProbability, analyzeProbabilityByCounts } from './analyzer/ProbAnalyzer'

export { GameOperator } from './operator/GameOperator'

export { suggestDiscard } from './suggestor/Suggestor'
