#define PROBLEM "http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_3_A"

include "../../template/template.nim"

proc main() =
  let p = stdin.readLine().split()
  var s = newSeq[int]()
  for t in p:
    if t == "+":
      let b, a = s.pop();s.add(a + b)
    elif t == "-":
      let b, a = s.pop();s.add(a - b)
    elif t == "*":
      let b, a = s.pop();s.add(b * a)
    else:
      s.add(parseInt(t))
  echo s.pop()

main()
