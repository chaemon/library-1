# verify-helper: PROBLEM http://judge.u-aizu.ac.jp/onlinejudge/description.jsp?id=ALDS1_3_C&lang=jp

include "template/template.nim"

import lists

proc main() =
  let n = nextInt()
  var l = initDoublyLinkedList[int]()
  for _ in 0..<n:
    let
      command = nextString()
    case command:
      of "insert":
        let key = nextInt()
        var nd = newDoublyLinkedNode[int](key)
        l.prepend(nd)
      of "delete":
        let key = nextInt()
        var dlist = newSeq[DoublyLinkedNode[int]]()
        for nd in l.nodes:
          if nd.value == key:
            l.remove(nd)
            break
      of "deleteFirst":
        l.remove(l.head)
      of "deleteLast":
        l.remove(l.tail)
  for nd in l.nodes:
    stdout.write nd.value
    if nd.next != nil:
      stdout.write " "
  echo ""

main()
