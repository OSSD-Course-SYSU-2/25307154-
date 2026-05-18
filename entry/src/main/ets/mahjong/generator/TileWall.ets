import { Tile, encodeTileIndexFromTile } from '../models/tile'
import { TileWall } from '../models/results'

export class TileWallImpl implements TileWall {
  private tiles: Tile[] = []
  private remainCountsMap: Map<number, number> = new Map()

  constructor(tiles: Tile[]) {
    this.tiles = []
    for (let i = 0; i < tiles.length; i++) {
      this.tiles.push(tiles[i])
    }
    this.rebuildCountMap()
  }

  private rebuildCountMap(): void {
    this.remainCountsMap = new Map()
    for (let i = 0; i < this.tiles.length; i++) {
      const idx = encodeTileIndexFromTile(this.tiles[i])
      const prev = this.remainCountsMap.get(idx)
      if (prev !== undefined) {
        this.remainCountsMap.set(idx, prev + 1)
      } else {
        this.remainCountsMap.set(idx, 1)
      }
    }
  }

  get totalRemaining(): number {
    return this.tiles.length
  }

  getRemainCount(tileIndex: number): number {
    const val = this.remainCountsMap.get(tileIndex)
    if (val !== undefined) {
      return val
    }
    return 0
  }

  drawRandom(): Tile | null {
    if (this.tiles.length === 0) {
      return null
    }
    const idx = Math.floor(Math.random() * this.tiles.length)
    const drawn = this.tiles[idx]
    this.tiles.splice(idx, 1)
    const tileIdx = encodeTileIndexFromTile(drawn)
    const current = this.remainCountsMap.get(tileIdx)
    if (current !== undefined) {
      if (current <= 1) {
        this.remainCountsMap.delete(tileIdx)
      } else {
        this.remainCountsMap.set(tileIdx, current - 1)
      }
    }
    return drawn
  }

  remove(tileIndex: number): boolean {
    let foundIdx = -1
    for (let i = 0; i < this.tiles.length; i++) {
      if (encodeTileIndexFromTile(this.tiles[i]) === tileIndex) {
        foundIdx = i
        break
      }
    }
    if (foundIdx === -1) {
      return false
    }
    this.tiles.splice(foundIdx, 1)
    const current = this.remainCountsMap.get(tileIndex)
    if (current !== undefined) {
      if (current <= 1) {
        this.remainCountsMap.delete(tileIndex)
      } else {
        this.remainCountsMap.set(tileIndex, current - 1)
      }
    }
    return true
  }
}
