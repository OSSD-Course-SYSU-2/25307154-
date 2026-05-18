export enum TileSuit {
  WAN = 'wan',
  TIAO = 'tiao',
  TONG = 'tong',
  ZI = 'zi'
}

export type TileFaceValue = number | 'zhong'

export enum HuType {
  PING_HU = 'ping_hu',
  QI_DUI = 'qi_dui',
  PENG_PENG_HU = 'peng_peng_hu'
}

export enum RiskTag {
  NONE = 'none',
  WILD_TILE_RISK = 'wild_tile_risk'
}

export enum ErrorCode {
  HAND_COUNT_EXCEED = 'HAND_COUNT_EXCEED',
  HAND_COUNT_INVALID = 'HAND_COUNT_INVALID',
  HAND_EMPTY = 'HAND_EMPTY',
  HAND_ILLEGAL_TILE = 'HAND_ILLEGAL_TILE',
  WALL_EMPTY = 'WALL_EMPTY',
  TILE_NOT_IN_HAND = 'TILE_NOT_IN_HAND',
  ALREADY_HU = 'ALREADY_HU',
  HAND_SIZE_ABNORMAL = 'HAND_SIZE_ABNORMAL',
  COMPUTE_BUDGET_EXCEEDED = 'COMPUTE_BUDGET_EXCEEDED',
  HU_CALL_LIMIT_EXCEEDED = 'HU_CALL_LIMIT_EXCEEDED',
  DEGRADED_RESULT = 'DEGRADED_RESULT'
}
