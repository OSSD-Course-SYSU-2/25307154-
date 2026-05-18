import { Tile } from '../models/tile'
import { ErrorCode } from '../types/enums'
import { Result, createSuccess, createError } from '../types/result'
import { TileWall } from '../models/results'
import { judgeHuByCounts } from '../judge/HuJudge'
import { tilesToCounts } from '../utils/handCounts'

export function validateDraw(wall: TileWall, isHu: boolean): Result<boolean> {
  if (isHu) {
    return createError<boolean>(ErrorCode.ALREADY_HU, '当前手牌已胡牌，无需继续操作')
  }
  if (wall.totalRemaining === 0) {
    return createError<boolean>(ErrorCode.WALL_EMPTY, '牌墙已空，无法摸牌')
  }
  return createSuccess<boolean>(true)
}

export function validateDiscard(handTiles: Tile[], discardTile: Tile, isHu: boolean): Result<boolean> {
  if (isHu) {
    return createError<boolean>(ErrorCode.ALREADY_HU, '当前手牌已胡牌，无需继续操作')
  }

  let found = false
  for (let i = 0; i < handTiles.length; i++) {
    if (handTiles[i].suit === discardTile.suit &&
        handTiles[i].faceValue === discardTile.faceValue &&
        handTiles[i].seqNo === discardTile.seqNo) {
      found = true
      break
    }
  }
  if (!found) {
    return createError<boolean>(ErrorCode.TILE_NOT_IN_HAND, '该牌不在手牌中，无法打出')
  }
  return createSuccess<boolean>(true)
}

export function checkIsHu(handTiles: Tile[]): boolean {
  const counts = tilesToCounts(handTiles)
  return judgeHuByCounts(counts).isHu
}
