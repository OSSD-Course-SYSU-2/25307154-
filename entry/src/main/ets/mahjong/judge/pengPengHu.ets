import { HandCounts } from '../utils/handCounts'
import { decomposeOnlyKezi } from './meldDecompose'

export function judgePengPengHu(counts: HandCounts): boolean {
  let total = 0
  for (let i = 0; i < counts.length; i++) {
    total += counts[i]
  }
  if (total % 3 !== 2) {
    return false
  }

  for (let pairIdx = 0; pairIdx < 27; pairIdx++) {
    if (counts[pairIdx] >= 2) {
      const reduced: number[] = []
      for (let i = 0; i < counts.length; i++) {
        reduced.push(counts[i])
      }
      reduced[pairIdx] = reduced[pairIdx] - 2
      if (checkOnlyKeziForAllSuits(reduced)) {
        return true
      }
    }
  }

  if (counts[27] >= 2) {
    const reduced: number[] = []
    for (let i = 0; i < counts.length; i++) {
      reduced.push(counts[i])
    }
    reduced[27] = reduced[27] - 2
    if (checkOnlyKeziForAllSuits(reduced)) {
      return true
    }
  }

  return false
}

function checkOnlyKeziForAllSuits(counts: number[]): boolean {
  const wan = counts.slice(0, 9)
  const tiao = counts.slice(9, 18)
  const tong = counts.slice(18, 27)

  if (counts[27] % 3 !== 0) {
    return false
  }

  return decomposeOnlyKezi(wan) && decomposeOnlyKezi(tiao) && decomposeOnlyKezi(tong)
}
