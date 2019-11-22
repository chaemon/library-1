#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_14_D"

include "../../template/template.nim"

include "../aho_corasick.nim"

proc main() =
  let
    S = nextString()
    Q = nextInt()

  var a = initAhoCorasick(26, 'a'.ord);
  for i in 0..<Q:
    let T = nextString()
    a.add(T)
  a.build(true)
  var
    ans = newSeq[int](Q)
    r = a.match(S)
  for k,v in r:
    ans[k] = 1
  for t in ans: echo t

main()
