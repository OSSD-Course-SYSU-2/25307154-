import { Tile } from '../models/tile'
import { TileSuit } from '../types/enums'

const SUIT_PRIORITY: Record<string, number> = {}
SUIT_PRIORITY[TileSuit.WAN] = 1
SUIT_PRIORITY[TileSuit.TIAO] = 2
SUIT_PRIORITY[TileSuit.TONG] = 3
SUIT_PRIORITY[TileSuit.ZI] = 4

function tileToString(tile: Tile): string {
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

export function sortHand(tiles: Tile[]): Tile[] {
  if (tiles.length === 0) {
    return []
  }
  const copied = tiles.slice()
  copied.sort((a, b) => {
    const suitA = SUIT_PRIORITY[a.suit]
    const suitB = SUIT_PRIORITY[b.suit]
    if (suitA !== suitB) {
      return suitA - suitB
    }
    const faceA = a.suit === TileSuit.ZI ? 0 : (a.faceValue as number)
    const faceB = b.suit === TileSuit.ZI ? 0 : (b.faceValue as number)
    return faceA - faceB
  })
  return copied
}

export function formatSortedHand(tiles: Tile[]): string {
  if (tiles.length === 0) {
    return ''
  }

  const groups: Tile[][] = []
  let currentGroup: Tile[] = [tiles[0]]

  for (let i = 1; i < tiles.length; i++) {
    if (tiles[i].suit === tiles[i - 1].suit) {
      currentGroup.push(tiles[i])
    } else {
      groups.push(currentGroup)
      currentGroup = [tiles[i]]
    }
  }
  groups.push(currentGroup)

  const groupStrings: string[] = []
  for (let i = 0; i < groups.length; i++) {
    const parts: string[] = []
    for (let j = 0; j < groups[i].length; j++) {
      parts.push(tileToString(groups[i][j]))
    }
    groupStrings.push(parts.join(' '))
  }

  return groupStrings.join(' | ')
}

export function groupBySuit(sortedTiles: Tile[]): Tile[][] {
  if (sortedTiles.length === 0) {
    return []
  }

  const groups: Tile[][] = []
  let currentGroup: Tile[] = [sortedTiles[0]]

  for (let i = 1; i < sortedTiles.length; i++) {
    if (sortedTiles[i].suit === sortedTiles[i - 1].suit) {
      currentGroup.push(sortedTiles[i])
    } else {
      groups.push(currentGroup)
      currentGroup = [sortedTiles[i]]
    }
  }
  groups.push(currentGroup)

  return groups
}
