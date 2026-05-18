import { Tile, TileType, encodeTileIndexFromTile, decodeTileIndex } from '../models/tile'

export type HandCounts = number[]

export function createEmptyHandCounts(): HandCounts {
  const arr: number[] = []
  for (let i = 0; i < 28; i++) {
    arr.push(0)
  }
  return arr
}

export function tilesToCounts(tiles: Tile[]): HandCounts {
  const counts = createEmptyHandCounts()
  for (let i = 0; i < tiles.length; i++) {
    const idx = encodeTileIndexFromTile(tiles[i])
    counts[idx] = counts[idx] + 1
  }
  return counts
}

export function countsToTileTypes(counts: HandCounts): TileType[] {
  const result: TileType[] = []
  for (let i = 0; i < 28; i++) {
    for (let j = 0; j < counts[i]; j++) {
      result.push(decodeTileIndex(i))
    }
  }
  return result
}

export function encodeHandCounts(counts: HandCounts): string {
  return counts.join(',')
}

export function getTotalCount(counts: HandCounts): number {
  let total = 0
  for (let i = 0; i < 28; i++) {
    total += counts[i]
  }
  return total
}

export function getWildCount(counts: HandCounts): number {
  return counts[27]
}

export function cloneHandCounts(counts: HandCounts): HandCounts {
  return [
    counts[0], counts[1], counts[2], counts[3], counts[4], counts[5], counts[6],
    counts[7], counts[8], counts[9], counts[10], counts[11], counts[12], counts[13],
    counts[14], counts[15], counts[16], counts[17], counts[18], counts[19], counts[20],
    counts[21], counts[22], counts[23], counts[24], counts[25], counts[26], counts[27]
  ]
}

export function addTileToCounts(counts: HandCounts, tileIndex: number): HandCounts {
  const cloned = cloneHandCounts(counts)
  cloned[tileIndex] = cloned[tileIndex] + 1
  return cloned
}

export function removeTileFromCounts(counts: HandCounts, tileIndex: number): HandCounts {
  const cloned = cloneHandCounts(counts)
  cloned[tileIndex] = cloned[tileIndex] - 1
  return cloned
}
