import { HandCounts } from '../utils/handCounts'
import { decomposeMelds } from './meldDecompose'

export function judgePingHu(counts: HandCounts): boolean {
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

      const wan = reduced.slice(0, 9)
      const tiao = reduced.slice(9, 18)
      const tong = reduced.slice(18, 27)

      if (decomposeMelds(wan) && decomposeMelds(tiao) && decomposeMelds(tong)) {
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

    const wan = reduced.slice(0, 9)
    const tiao = reduced.slice(9, 18)
    const tong = reduced.slice(18, 27)
    const ziRemaining = reduced[27]

    if (ziRemaining === 0) {
      if (decomposeMelds(wan) && decomposeMelds(tiao) && decomposeMelds(tong)) {
        return true
      }
    }
  }

  return false
}
