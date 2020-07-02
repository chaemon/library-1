# verify-helper: PROBLEM https://judge.yosupo.jp/problem/two_sat

include "template/template.nim"
include "graph/template.nim"

include "graph/strongly_connected_components.nim"
include "graph/two_satisfability.nim"

proc main() =
  let p, cnf = nextString()
  let N, M = nextInt()
  var s = initTwoSat(N)
  for i in 0..<M:
    var a, b, c = nextInt()
    if a > 0:
      a = a - 1
    else:
      a = s.rev(-a - 1)
    if b > 0:
      b = b - 1
    else:
      b = s.rev(-b - 1)
    s.addLiteral(a, b)
  if not s.solve():
    echo "s UNSATISFIABLE";return
  echo "s SATISFIABLE"
  stdout.write("v")
  for u in 0..<N:
    stdout.write(" ")
    if s[u]: stdout.write(u + 1)
    else: stdout.write(- (u + 1))
  echo " 0"

main()
