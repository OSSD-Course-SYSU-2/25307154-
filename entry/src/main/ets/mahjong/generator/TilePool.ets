import { TileSuit } from '../types/enums'
import { Tile, encodeTileIndexFromTile } from '../models/tile'
import { getRuleConfig } from '../config/RuleConfig'

export class TilePool {
  private allTiles: Tile[] = []
  private remaining: Tile[] = []

  initialize(): void {
    this.allTiles = []
    const config = getRuleConfig()

    const suits: TileSuit[] = [TileSuit.WAN, TileSuit.TIAO, TileSuit.TONG]
    for (let s = 0; s < suits.length; s++) {
      const suit = suits[s]
      for (let faceValue = 1; faceValue <= 9; faceValue++) {
        for (let seqNo = 1; seqNo <= config.tileCopiesPerType; seqNo++) {
          this.allTiles.push({ suit: suit, faceValue: faceValue, seqNo: seqNo })
        }
      }
    }

    for (let seqNo = 1; seqNo <= config.tileCopiesPerType; seqNo++) {
      this.allTiles.push({ suit: TileSuit.ZI, faceValue: 'zhong', seqNo: seqNo })
    }

    this.remaining = []
    for (let i = 0; i < this.allTiles.length; i++) {
      this.remaining.push(this.allTiles[i])
    }
  }

  shuffle(): void {
    const n = this.remaining.length
    for (let i = n - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1))
      const temp = this.remaining[i]
      this.remaining[i] = this.remaining[j]
      this.remaining[j] = temp
    }
  }

  drawRandomN(count: number): Tile[] {
    this.shuffle()
    const drawn: Tile[] = []
    for (let i = 0; i < count && i < this.remaining.length; i++) {
      drawn.push(this.remaining[i])
    }
    this.remaining = this.remaining.slice(count)
    return drawn
  }

  drawOne(): Tile | null {
    if (this.remaining.length === 0) {
      return null
    }
    const idx = Math.floor(Math.random() * this.remaining.length)
    const tile = this.remaining[idx]
    this.remaining.splice(idx, 1)
    return tile
  }

  getRemaining(): Tile[] {
    const result: Tile[] = []
    for (let i = 0; i < this.remaining.length; i++) {
      result.push(this.remaining[i])
    }
    return result
  }

  getRemainingCount(): number {
    return this.remaining.length
  }

  getRemainCountsByIndex(): Map<number, number> {
    const counts = new Map<number, number>()
    for (let i = 0; i < this.remaining.length; i++) {
      const idx = encodeTileIndexFromTile(this.remaining[i])
      const prev = counts.get(idx)
      if (prev !== undefined) {
        counts.set(idx, prev + 1)
      } else {
        counts.set(idx, 1)
      }
    }
    return counts
  }

  getAllTiles(): Tile[] {
    const result: Tile[] = []
    for (let i = 0; i < this.allTiles.length; i++) {
      result.push(this.allTiles[i])
    }
    return result
  }

  getTotalCount(): number {
    return this.allTiles.length
  }
}
