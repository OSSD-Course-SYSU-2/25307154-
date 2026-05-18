import { TileSuit, HuType } from '../types/enums'
import { TileType } from '../models/tile'

export interface FaceValueRange {
  min: number
  max: number
}

export interface RuleConfig {
  suits: TileSuit[]
  faceValueRange: FaceValueRange
  wildTile: TileType
  enabledHuTypes: HuType[]
  standardHandSize: number
  tileCopiesPerType: number
  totalTileCount: number
}

const DEFAULT_WILD_TILE: TileType = { suit: TileSuit.ZI, faceValue: 'zhong' }

let currentConfig: RuleConfig = createDefaultConfig()
function createDefaultConfig(): RuleConfig {
  const faceValueRange: FaceValueRange = { min: 1, max: 9 }
  const config: RuleConfig = {
    suits: [TileSuit.WAN, TileSuit.TIAO, TileSuit.TONG, TileSuit.ZI],
    faceValueRange: faceValueRange,
    wildTile: DEFAULT_WILD_TILE,
    enabledHuTypes: [HuType.PING_HU, HuType.QI_DUI, HuType.PENG_PENG_HU],
    standardHandSize: 13,
    tileCopiesPerType: 4,
    totalTileCount: 112
  }
  return config
}

export function getRuleConfig(): RuleConfig {
  return currentConfig
}
export function setWildTile(tile: TileType): void {
  currentConfig = {
    suits: currentConfig.suits,
    faceValueRange: currentConfig.faceValueRange,
    wildTile: tile,
    enabledHuTypes: currentConfig.enabledHuTypes,
    standardHandSize: currentConfig.standardHandSize,
    tileCopiesPerType: currentConfig.tileCopiesPerType,
    totalTileCount: currentConfig.totalTileCount
  }
}

export function resetRuleConfig(): void {
  currentConfig = createDefaultConfig()
}
