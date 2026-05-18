import { TileSuit, TileFaceValue } from '../types/enums'

export interface TileType {
  suit: TileSuit
  faceValue: TileFaceValue
}

export interface Tile {
  suit: TileSuit
  faceValue: TileFaceValue
  seqNo: number
}

export function encodeTileIndex(tile: TileType): number {
  if (tile.suit === TileSuit.ZI) {
    return 27
  }
  const fv = tile.faceValue
  if (tile.suit === TileSuit.WAN) {
    return (fv as number) - 1
  }
  if (tile.suit === TileSuit.TIAO) {
    return 9 + (fv as number) - 1
  }
  return 18 + (fv as number) - 1
}

export function encodeTileIndexFromTile(tile: Tile): number {
  if (tile.suit === TileSuit.ZI) {
    return 27
  }
  const fv = tile.faceValue
  if (tile.suit === TileSuit.WAN) {
    return (fv as number) - 1
  }
  if (tile.suit === TileSuit.TIAO) {
    return 9 + (fv as number) - 1
  }
  return 18 + (fv as number) - 1
}

export function decodeTileIndex(index: number): TileType {
  if (index === 27) {
    return { suit: TileSuit.ZI, faceValue: 'zhong' }
  }
  if (index < 9) {
    return { suit: TileSuit.WAN, faceValue: index + 1 }
  }
  if (index < 18) {
    return { suit: TileSuit.TIAO, faceValue: index - 9 + 1 }
  }
  return { suit: TileSuit.TONG, faceValue: index - 18 + 1 }
}

export function tileTypeEquals(a: TileType, b: TileType): boolean {
  return a.suit === b.suit && a.faceValue === b.faceValue
}

export function tileTypeToString(tile: TileType): string {
  if (tile.suit === TileSuit.ZI) {
    return '红中'
  }
  if (tile.suit === TileSuit.WAN) {
    return `${tile.faceValue}万`
  }
  if (tile.suit === TileSuit.TIAO) {
    return `${tile.faceValue}条`
  }
  return `${tile.faceValue}筒`
}

export function tileToTileType(tile: Tile): TileType {
  return { suit: tile.suit, faceValue: tile.faceValue }
}
