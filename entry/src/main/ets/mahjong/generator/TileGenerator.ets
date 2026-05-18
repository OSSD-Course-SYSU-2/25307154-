import { Result, createSuccess, createError } from '../types/result'
import { ErrorCode } from '../types/enums'
import { HandInfo } from '../models/results'
import { getRuleConfig } from '../config/RuleConfig'
import { TilePool } from './TilePool'
import { TileWallImpl } from './TileWall'

export class TileGenerator {
  private pool: TilePool = new TilePool()
  private _wall: TileWallImpl | null = null

  get wall(): TileWallImpl | null {
    return this._wall
  }

  generateHand(count?: number): Result<HandInfo> {
    const config = getRuleConfig()
    let handCount = config.standardHandSize
    if (count !== undefined && count !== null) {
      handCount = count
    }

    if (handCount <= 0) {
      return createError<HandInfo>(ErrorCode.HAND_COUNT_INVALID, '手牌张数必须为正整数')
    }

    this.pool.initialize()

    if (handCount > this.pool.getRemainingCount()) {
      return createError<HandInfo>(ErrorCode.HAND_COUNT_EXCEED, '手牌张数超过牌池剩余数量')
    }

    const tiles = this.pool.drawRandomN(handCount)
    const remaining = this.pool.getRemaining()
    this._wall = new TileWallImpl(remaining)

    const wallRem = this._wall.totalRemaining
    return createSuccess<HandInfo>({
      tiles: tiles,
      wallRemaining: wallRem
    })
  }

  getPool(): TilePool {
    return this.pool
  }
}
