include "../../template/template.nim"
include "../trie.nim"

proc main() =
  var trie = initTrie(26, 'a'.ord)
  let
    S = nextString()
    M = nextInt()
    P = newSeqWith(M, nextString())
    W = newSeqWith(M, nextInt())
  var dp = newSeqWith(S.len + 1, 0)
  for i in 0..<M: trie.add(P[i])
  for i in 0..<S.len:
    let update = (idx:int) => (dp[i + P[idx].len] = max(dp[i + P[idx].len], dp[i] + W[idx]))
    trie.query(S, update, i, 0)
    dp[i + 1] = max(dp[i + 1], dp[i])
  echo dp[^1]

main()
