#{{{ Deque[T]
import math, typetraits

type
  Deque*[T] = object
    ## A double-ended queue backed with a ringed seq buffer.
    ##
    ## To initialize an empty deque use `initDeque proc <#initDeque,int>`_.
    data: seq[T]
    head, tail, count, mask: int

proc initDeque*[T](initialSize: int = 4): Deque[T] =
  ## Create a new empty deque.
  ##
  ## Optionally, the initial capacity can be reserved via `initialSize`
  ## as a performance optimization.
  ## The length of a newly created deque will still be 0.
  ##
  ## ``initialSize`` must be a power of two (default: 4).
  ## If you need to accept runtime values for this you could use the
  ## `nextPowerOfTwo proc<math.html#nextPowerOfTwo,int>`_ from the
  ## `math module<math.html>`_.
  assert isPowerOfTwo(initialSize)
  result.mask = initialSize-1
  newSeq(result.data, initialSize)

proc len*[T](deq: Deque[T]): int {.inline.} =
  ## Return the number of elements of `deq`.
  result = deq.count

template emptyCheck(deq) =
  # Bounds check for the regular deque access.
  when compileOption("boundChecks"):
    if unlikely(deq.count < 1):
      raise newException(IndexError, "Empty deque.")

template xBoundsCheck(deq, i) =
  # Bounds check for the array like accesses.
  when compileOption("boundChecks"): # d:release should disable this.
    if unlikely(i >= deq.count): # x < deq.low is taken care by the Natural parameter
      raise newException(IndexError,
                         "Out of bounds: " & $i & " > " & $(deq.count - 1))
    if unlikely(i < 0): # when used with BackwardsIndex
      raise newException(IndexError,
                         "Out of bounds: " & $i & " < 0")

proc `[]`*[T](deq: Deque[T], i: Natural): T {.inline.} =
  ## Access the i-th element of `deq`.

  xBoundsCheck(deq, i)
  return deq.data[(deq.head + i) and deq.mask]

proc `[]`*[T](deq: var Deque[T], i: Natural): var T {.inline.} =
  ## Access the i-th element of `deq` and return a mutable
  ## reference to it.
  xBoundsCheck(deq, i)
  return deq.data[(deq.head + i) and deq.mask]

proc `[]=`*[T](deq: var Deque[T], i: Natural, val: T) {.inline.} =
  ## Change the i-th element of `deq`.

  xBoundsCheck(deq, i)
  deq.data[(deq.head + i) and deq.mask] = val

iterator items*[T](deq: Deque[T]): T =
  ## Yield every element of `deq`.
  ##
  ## **Examples:**
  ##
  ## .. code-block::
  ##   var a = initDeque[int]()
  ##   for i in 1 .. 3:
  ##     a.addLast(10*i)
  ##
  ##   for x in a:  # the same as: for x in items(a):
  ##     echo x
  ##
  ##   # 10
  ##   # 20
  ##   # 30
  ##
  var i = deq.head
  for c in 0 ..< deq.count:
    yield deq.data[i]
    i = (i + 1) and deq.mask

iterator mitems*[T](deq: var Deque[T]): var T =
  ## Yield every element of `deq`, which can be modified.

  var i = deq.head
  for c in 0 ..< deq.count:
    yield deq.data[i]
    i = (i + 1) and deq.mask

iterator pairs*[T](deq: Deque[T]): tuple[key: int, val: T] =
  ## Yield every (position, value) of `deq`.
  ##
  ## **Examples:**
  ##
  ## .. code-block::
  ##   var a = initDeque[int]()
  ##   for i in 1 .. 3:
  ##     a.addLast(10*i)
  ##
  ##   for k, v in pairs(a):
  ##     echo "key: ", k, ", value: ", v
  ##
  ##   # key: 0, value: 10
  ##   # key: 1, value: 20
  ##   # key: 2, value: 30
  ##
  var i = deq.head
  for c in 0 ..< deq.count:
    yield (c, deq.data[i])
    i = (i + 1) and deq.mask

proc contains*[T](deq: Deque[T], item: T): bool {.inline.} =
  ## Return true if `item` is in `deq` or false if not found.
  ##
  ## Usually used via the ``in`` operator.
  ## It is the equivalent of ``deq.find(item) >= 0``.
  ##
  ## .. code-block:: Nim
  ##   if x in q:
  ##     assert q.contains(x)
  for e in deq:
    if e == item: return true
  return false

proc expandIfNeeded[T](deq: var Deque[T]) =
  var cap = deq.mask + 1
  if unlikely(deq.count >= cap):
    var n = newSeq[T](cap * 2)
    for i, x in pairs(deq): # don't use copyMem because the GC and because it's slower.
      shallowCopy(n[i], x)
    shallowCopy(deq.data, n)
    deq.mask = cap * 2 - 1
    deq.tail = deq.count
    deq.head = 0

proc addFirst*[T](deq: var Deque[T], item: T) =
  ## Add an `item` to the beginning of the `deq`.
  ##
  ## See also:
  ## * `addLast proc <#addLast,Deque[T],T>`_
  ## * `peekFirst proc <#peekFirst,Deque[T]>`_
  ## * `peekLast proc <#peekLast,Deque[T]>`_
  ## * `popFirst proc <#popFirst,Deque[T]>`_
  ## * `popLast proc <#popLast,Deque[T]>`_

  expandIfNeeded(deq)
  inc deq.count
  deq.head = (deq.head - 1) and deq.mask
  deq.data[deq.head] = item

proc addLast*[T](deq: var Deque[T], item: T) =
  ## Add an `item` to the end of the `deq`.
  ##
  ## See also:
  ## * `addFirst proc <#addFirst,Deque[T],T>`_
  ## * `peekFirst proc <#peekFirst,Deque[T]>`_
  ## * `peekLast proc <#peekLast,Deque[T]>`_
  ## * `popFirst proc <#popFirst,Deque[T]>`_
  ## * `popLast proc <#popLast,Deque[T]>`_

  expandIfNeeded(deq)
  inc deq.count
  deq.data[deq.tail] = item
  deq.tail = (deq.tail + 1) and deq.mask

proc peekFirst*[T](deq: Deque[T]): T {.inline.} =
  ## Returns the first element of `deq`, but does not remove it from the deque.
  ##
  ## See also:
  ## * `addFirst proc <#addFirst,Deque[T],T>`_
  ## * `addLast proc <#addLast,Deque[T],T>`_
  ## * `peekLast proc <#peekLast,Deque[T]>`_
  ## * `popFirst proc <#popFirst,Deque[T]>`_
  ## * `popLast proc <#popLast,Deque[T]>`_

  emptyCheck(deq)
  result = deq.data[deq.head]

proc peekLast*[T](deq: Deque[T]): T {.inline.} =
  ## Returns the last element of `deq`, but does not remove it from the deque.
  ##
  ## See also:
  ## * `addFirst proc <#addFirst,Deque[T],T>`_
  ## * `addLast proc <#addLast,Deque[T],T>`_
  ## * `peekFirst proc <#peekFirst,Deque[T]>`_
  ## * `popFirst proc <#popFirst,Deque[T]>`_
  ## * `popLast proc <#popLast,Deque[T]>`_

  emptyCheck(deq)
  result = deq.data[(deq.tail - 1) and deq.mask]

template destroy(x: untyped) =
  reset(x)

proc popFirst*[T](deq: var Deque[T]): T {.inline, discardable.} =
  ## Remove and returns the first element of the `deq`.
  ##
  ## See also:
  ## * `addFirst proc <#addFirst,Deque[T],T>`_
  ## * `addLast proc <#addLast,Deque[T],T>`_
  ## * `peekFirst proc <#peekFirst,Deque[T]>`_
  ## * `peekLast proc <#peekLast,Deque[T]>`_
  ## * `popLast proc <#popLast,Deque[T]>`_
  ## * `clear proc <#clear,Deque[T]>`_
  ## * `shrink proc <#shrink,Deque[T],int,int>`_

  emptyCheck(deq)
  dec deq.count
  result = deq.data[deq.head]
  destroy(deq.data[deq.head])
  deq.head = (deq.head + 1) and deq.mask

proc popLast*[T](deq: var Deque[T]): T {.inline, discardable.} =
  ## Remove and returns the last element of the `deq`.
  ##
  ## See also:
  ## * `addFirst proc <#addFirst,Deque[T],T>`_
  ## * `addLast proc <#addLast,Deque[T],T>`_
  ## * `peekFirst proc <#peekFirst,Deque[T]>`_
  ## * `peekLast proc <#peekLast,Deque[T]>`_
  ## * `popFirst proc <#popFirst,Deque[T]>`_
  ## * `clear proc <#clear,Deque[T]>`_
  ## * `shrink proc <#shrink,Deque[T],int,int>`_

  emptyCheck(deq)
  dec deq.count
  deq.tail = (deq.tail - 1) and deq.mask
  result = deq.data[deq.tail]
  destroy(deq.data[deq.tail])

proc clear*[T](deq: var Deque[T]) {.inline.} =
  ## Resets the deque so that it is empty.
  ##
  ## See also:
  ## * `clear proc <#clear,Deque[T]>`_
  ## * `shrink proc <#shrink,Deque[T],int,int>`_

  for el in mitems(deq): destroy(el)
  deq.count = 0
  deq.tail = deq.head

proc shrink*[T](deq: var Deque[T], fromFirst = 0, fromLast = 0) =
  ## Remove `fromFirst` elements from the front of the deque and
  ## `fromLast` elements from the back.
  ##
  ## If the supplied number of elements exceeds the total number of elements
  ## in the deque, the deque will remain empty.
  ##
  ## See also:
  ## * `clear proc <#clear,Deque[T]>`_

  if fromFirst + fromLast > deq.count:
    clear(deq)
    return

  for i in 0 ..< fromFirst:
    destroy(deq.data[deq.head])
    deq.head = (deq.head + 1) and deq.mask

  for i in 0 ..< fromLast:
    destroy(deq.data[deq.tail])
    deq.tail = (deq.tail - 1) and deq.mask

  dec deq.count, fromFirst + fromLast

proc `$`*[T](deq: Deque[T]): string =
  ## Turn a deque into its string representation.
  result = "["
  for x in deq:
    if result.len > 1: result.add(", ")
    result.addQuoted(x)
  result.add("]")
#}}}
