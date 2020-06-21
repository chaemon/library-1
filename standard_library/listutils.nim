# split/merge of list {{{
proc split(f:var DoublyLinkedList[int], nd:DoublyLinkedNode[int]):DoublyLinkedList[int] =
  let tmp = f.tail
  result = initDoublyLinkedList[int]()
  result.tail = f.tail
  result.head = nd
  f.tail = nd.prev
  if f.head == nd:
    f.head = nil
    f.tail = nil
  if nd.prev != nil:
    nd.prev.next = nil
  nd.prev = nil

proc merge(f, t:var DoublyLinkedList[int]) =
  if f.tail == nil:
    doAssert(f.head == nil)
    f.head = t.head
    f.tail = t.tail
  else:
    f.tail.next = t.head
    t.head.prev = f.tail
    f.tail = t.tail
# }}}
