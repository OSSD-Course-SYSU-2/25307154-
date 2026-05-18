import { HandCounts } from '../utils/handCounts'

export function judgeQiDui(counts: HandCounts): boolean {
  let pairCount = 0
  const wildCount = counts[27]

  for (let i = 0; i < 27; i++) {
    if (counts[i] >= 2) {
      pairCount += Math.floor(counts[i] / 2)
    }
  }

  const wildPairsFromWild = Math.floor(wildCount / 2)
  let totalPairs = pairCount + wildPairsFromWild

  let remainingWild = wildCount - wildPairsFromWild * 2
  let fillable = 0
  for (let i = 0; i < 27; i++) {
    if (counts[i] % 2 === 1 && remainingWild > 0) {
      fillable++
      remainingWild--
    }
  }
  totalPairs += fillable
  totalPairs += Math.floor(remainingWild / 2)

  return totalPairs >= 7
}
