export function decomposeMelds(tileCounts: number[]): boolean {
  const counts = [...tileCounts]
  return decomposeRec(counts, 0)
}

function decomposeRec(counts: number[], start: number): boolean {
  let idx = -1
  for (let i = start; i < 9; i++) {
    if (counts[i] > 0) {
      idx = i
      break
    }
  }

  if (idx === -1) {
    return true
  }

  if (counts[idx] >= 3) {
    counts[idx] -= 3
    if (decomposeRec(counts, idx)) {
      counts[idx] += 3
      return true
    }
    counts[idx] += 3
  }

  if (idx <= 6 && counts[idx + 1] > 0 && counts[idx + 2] > 0) {
    counts[idx] -= 1
    counts[idx + 1] -= 1
    counts[idx + 2] -= 1
    if (decomposeRec(counts, idx)) {
      counts[idx] += 1
      counts[idx + 1] += 1
      counts[idx + 2] += 1
      return true
    }
    counts[idx] += 1
    counts[idx + 1] += 1
    counts[idx + 2] += 1
  }

  return false
}

export function decomposeOnlyKezi(tileCounts: number[]): boolean {
  const counts = [...tileCounts]
  for (let i = 0; i < 9; i++) {
    if (counts[i] % 3 !== 0) {
      return false
    }
  }
  return true
}
