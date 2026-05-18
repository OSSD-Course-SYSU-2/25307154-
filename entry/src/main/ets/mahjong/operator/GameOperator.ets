import { Tile } from '../models/tile'
import { Result, createSuccess, createError } from '../types/result'
import { ErrorCode } from '../types/enums'
import { DrawResult, DiscardResult, HuJudgeResult, ProbabilityResult, TileWall } from '../models/results'
import { TileWallImpl } from '../generator/TileWall'
import { judgeHu } from '../judge/HuJudge'
import { analyzeProbability } from '../analyzer/ProbAnalyzer'
import { validateDraw, validateDiscard, checkIsHu } from './validators'

export class GameOperator {
  private handTiles: Tile[] = []
  private wall: TileWallImpl | null = null
  private _isHu: boolean = false

  get hand(): Tile[] {
    const result: Tile[] = []
    for (let i = 0; i < this.handTiles.length; i++) {
      result.push(this.handTiles[i])
    }
    return result
  }

  get tileWall(): TileWall | null {
    return this.wall
  }

  get isHu(): boolean {
    return this._isHu
  }

  setHandAndWall(tiles: Tile[], wall: TileWallImpl): void {
    this.handTiles = []
    for (let i = 0; i < tiles.length; i++) {
      this.handTiles.push(tiles[i])
    }
    this.wall = wall
    this._isHu = checkIsHu(this.handTiles)
  }

  drawTile(): Result<DrawResult> {
    if (this.wall === null) {
      return createError<DrawResult>(ErrorCode.WALL_EMPTY, '牌墙未初始化')
    }

    const validateResult = validateDraw(this.wall, this._isHu)
    if (!validateResult.success) {
      const ec = validateResult.errorCode
      const em = validateResult.errorMessage
      return createError<DrawResult>(ec !== null ? ec : '', em !== null ? em : '')
    }

    const drawn = this.wall.drawRandom()
    if (drawn === null) {
      return createError<DrawResult>(ErrorCode.WALL_EMPTY, '牌墙已空，无法摸牌')
    }

    this.handTiles.push(drawn)

    const huResult = judgeHu(this.handTiles)
    let huJudgeResult: HuJudgeResult
    if (huResult.success && huResult.data !== null) {
      huJudgeResult = huResult.data
    } else {
      huJudgeResult = { isHu: false, huTypes: [], shantenNumber: 0, isDegraded: false, degradeReason: '' }
    }

    if (huJudgeResult.isHu) {
      this._isHu = true
    }

    const currentHand: Tile[] = []
    for (let i = 0; i < this.handTiles.length; i++) {
      currentHand.push(this.handTiles[i])
    }

    return createSuccess<DrawResult>({
      drawnTile: drawn,
      handTiles: currentHand,
      wallRemaining: this.wall.totalRemaining,
      huJudgeResult: huJudgeResult
    })
  }

  discardTile(tile: Tile): Result<DiscardResult> {
    const validateResult = validateDiscard(this.handTiles, tile, this._isHu)
    if (!validateResult.success) {
      const ec = validateResult.errorCode
      const em = validateResult.errorMessage
      return createError<DiscardResult>(ec !== null ? ec : '', em !== null ? em : '')
    }

    let foundIdx = -1
    for (let i = 0; i < this.handTiles.length; i++) {
      if (this.handTiles[i].suit === tile.suit &&
          this.handTiles[i].faceValue === tile.faceValue &&
          this.handTiles[i].seqNo === tile.seqNo) {
        foundIdx = i
        break
      }
    }
    if (foundIdx === -1) {
      return createError<DiscardResult>(ErrorCode.TILE_NOT_IN_HAND, '该牌不在手牌中，无法打出')
    }

    this.handTiles.splice(foundIdx, 1)

    if (this.wall === null) {
      return createError<DiscardResult>(ErrorCode.WALL_EMPTY, '牌墙未初始化')
    }

    const probResult = analyzeProbability(this.handTiles, this.wall)
    let probabilityResult: ProbabilityResult
    if (probResult.success && probResult.data !== null) {
      probabilityResult = probResult.data
    } else {
      probabilityResult = { shantenNumber: -1, tingList: [], effectiveDraws: [], huProbability: 0 }
    }

    const currentHand: Tile[] = []
    for (let i = 0; i < this.handTiles.length; i++) {
      currentHand.push(this.handTiles[i])
    }

    return createSuccess<DiscardResult>({
      handTiles: currentHand,
      probabilityResult: probabilityResult
    })
  }
}
