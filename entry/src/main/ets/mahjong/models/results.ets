import { HuType, RiskTag } from '../types/enums'
import { TileType, Tile } from './tile'

export interface HuJudgeResult {
  isHu: boolean
  huTypes: HuType[]
  shantenNumber: number
  isDegraded: boolean
  degradeReason: string
}

export interface TingItem {
  tile: TileType
  remainCount: number
}

export interface DrawItem {
  tile: TileType
  remainCount: number
}

export interface ProbabilityResult {
  shantenNumber: number
  tingList: TingItem[]
  effectiveDraws: DrawItem[]
  huProbability: number
}

export interface SuggestionItem {
  discardTiles: TileType[]
  shantenAfterDiscard: number
  effectiveDrawCount: number
  drawTiles: TileType[]
  riskTag: RiskTag
}

export interface SuggestResult {
  suggestions: SuggestionItem[]
  isComplete: boolean
  completedCount: number
  totalCount: number
  isDegraded: boolean
  degradeReason: string
}

export interface HandInfo {
  tiles: Tile[]
  wallRemaining: number
}

export interface DrawResult {
  drawnTile: Tile
  handTiles: Tile[]
  wallRemaining: number
  huJudgeResult: HuJudgeResult
}

export interface DiscardResult {
  handTiles: Tile[]
  probabilityResult: ProbabilityResult
}

export interface TileWall {
  totalRemaining: number
  getRemainCount(tileIndex: number): number
  drawRandom(): Tile | null
  remove(tileIndex: number): boolean
}
