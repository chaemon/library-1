import tables
include "../structure/trie.nim"
include "../standard_library/deque.nim"

type AhoCorasick = object of Trie
  FAIL: int
  correct: seq[int]

proc initAhoCorasick(char_sz, margin: int): AhoCorasick =
  var nodes = newSeq[TrieNode]()
  nodes.add(newTrieNode(char_sz + 1))
  AhoCorasick(char_sz: char_sz + 1, margin: margin, nodes:nodes, FAIL: char_sz, correct: newSeq[int]())

proc setUnion[T](u, v: seq[T]):seq[T] =
  result = newSeq[T]()
  var (i,j) = (0,0)
  while true:
    if i < u.len:
      if j < v.len:
        if u[i] < v[j]:result.add(u[i]);i+=1
        elif u[i] > v[j]:result.add(v[j]);j+=1
        else: result.add(v[j]);i+=1;j+=1
      else:
        result.add(u[i]);i+=1
    else:
      if j < v.len:
        result.add(v[j]);j+=1
      else:
        break
#  echo u, v, result

proc build(self: var AhoCorasick, heavy = true):void =
  self.correct.setLen(self.size)
  for i in 0..<self.size:
    self.correct[i] = self.nodes[i].accept.len

  var que = initDeque[int]()
  for i in 0..<self.char_sz:
    if self.nodes[0].nxt[i] != -1:
      self.nodes[self.nodes[0].nxt[i]].nxt[self.FAIL] = 0
      que.addLast(self.nodes[0].nxt[i])
    else:
      self.nodes[0].nxt[i] = 0
  while que.len > 0:
    let f = que.popFirst()
    var now = self.nodes[f].addr
    let fail = now[].nxt[self.FAIL]
    self.correct[f] += self.correct[fail]
    for i in 0..<self.char_sz-1:
      if now[].nxt[i] != -1:
        self.nodes[now.nxt[i]].nxt[self.FAIL] = self.nodes[fail].nxt[i]
        if heavy:
          var
            u = self.nodes[now.nxt[i]].accept.addr
            v = self.nodes[self.nodes[fail].nxt[i]].accept.addr
#            accept = newSeq[int]()
#          set_union(begin(u), end(u), begin(v), end(v), back_inserter(accept))
          u[] = setUnion(u[], v[])
        que.addLast(now[].nxt[i])
      else:
        now[].nxt[i] = self.nodes[fail].nxt[i]

proc match(self: AhoCorasick, str: string, now = 0):Table[int,seq[int]] =
  var now = now
  result = initTable[int,seq[int]]()
  for i, c in str:
#    while self.nodes[now].nxt[c.ord - self.margin] == -1: now = self.nodes[now].nxt[self.FAIL]
    now = self.nodes[now].nxt[c.ord - self.margin]
    for v in self.nodes[now].accept:
      if v notin result: result[v] = newSeq[int]()
      result[v].add(i)

proc move(self: AhoCorasick, c:char, now = 0):(int,int) =
  var now = self.nodes[now].nxt[c.ord - self.margin]
  return (self.correct[now], now)

proc move(self: AhoCorasick, str:string, now = 0):(int,int) =
  var now = now
  var sum = 0
  for c in str:
    let nxt = self.move(c, now)
    sum += nxt[0]
    now = nxt[1]
  return (sum, now)

