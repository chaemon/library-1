import sequtils, future

type
  TrieNode = ref object
    exist: int
    nxt, accept: seq[int]
  Trie = object of RootObj
    char_sz, margin: int
    nodes: seq[TrieNode]

proc newTrieNode(char_sz:int): TrieNode =
  return TrieNode(nxt: newSeqWith(char_sz, -1), exist: 0, accept: newSeq[int]())
proc initTrie(char_sz, margin: int): Trie =
  var nodes = newSeq[TrieNode]()
  nodes.add(newTrieNode(char_sz))
  return Trie(char_sz: char_sz, margin: margin, nodes:nodes)

proc updateDirect(self: var Trie, node, id:int) =
  self.nodes[node].accept.add(id)

proc updateChild(self: var Trie, node, child, id:int) =
  self.nodes[node].exist += 1

proc add(self: var Trie, str: string, str_index, node_index, id:int) =
  if str_index == str.len:
    self.update_direct(node_index, id)
  else:
    let c = str[str_index].ord - self.margin
    if self.nodes[node_index].nxt[c] == -1:
      self.nodes[node_index].nxt[c] = self.nodes.len
      self.nodes.add(newTrieNode(self.char_sz))
    self.add(str, str_index + 1, self.nodes[node_index].nxt[c], id)
    self.updateChild(node_index, self.nodes[node_index].nxt[c], id)

proc add(self: var Trie, str:string, id:int) =
  self.add(str, 0, 0, id)

proc add(self: var Trie, str:string) =
  self.add(str, self.nodes[0].exist)

proc query(self: Trie, str:string, f:(idx:int)->void , str_index, node_index:int) =
  for idx in self.nodes[node_index].accept: f(idx)
  if str_index == str.len: return
  else:
    let c = str[str_index].ord - self.margin
    if self.nodes[node_index].nxt[c] == -1: return
    self.query(str, f, str_index + 1, self.nodes[node_index].nxt[c])

proc query(self: Trie, str:string, f:(idx:int)->void) =
  self.query(str, f, 0, 0)

proc count(self: Trie):int =
  return self.nodes[0].exist

proc size(self: Trie):int =
  return self.nodes.len
