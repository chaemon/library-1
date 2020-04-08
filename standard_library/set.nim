# set and multiset library from C++ {{{
type CSet {.importcpp: "std::set", header: "<set>".} [T] = object
type CSetIter {.importcpp: "std::set<'0>::iterator", header: "<set>".} [T] = object
proc cInitSet(T: typedesc): CSet[T] {.importcpp: "std::set<'*1>()", nodecl.}
proc initSet*[T](): CSet[T] = cInitSet(T)

type CMultiSet {.importcpp: "std::multiset", header: "<set>".} [T] = object
type CMultiSetIter {.importcpp: "std::multiset<'0>::iterator", header: "<set>".} [T] = object
proc cInitMultiSet(T: typedesc): CMultiSet[T] {.importcpp: "std::multiset<'*1>()", nodecl.}
proc initMultiSet*[T](): CMultiSet[T] = cInitMultiSet(T)

type
  SomeSet[T] = CSet[T]|CMultiSet[T]
  SomeSetIter[T] = CSetIter[T]|CMultiSetIter[T]

proc insert*[T](self: var SomeSet[T],x:T) {.importcpp: "#.insert(@)", nodecl.}
proc empty*[T](self: SomeSet[T]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T](self: SomeSet[T]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T](self:var SomeSet[T]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T](self: var SomeSet[T],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc erase*[T](self: var SomeSet[T],x:SomeSetIter[T]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T](self: SomeSet[T],x:T): SomeSetIter[T] {.importcpp: "#.find(#)", nodecl.}
proc lowerBound*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc lowerBound*[T](self: CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upperBound*[T](self: CSet[T],x:T): CSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc upperBound*[T](self: CMultiSet[T],x:T): CMultiSetIter[T] {.importcpp: "#.upper_bound(#)", nodecl.}
proc Begin*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc Begin*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.begin()", nodecl.}
proc End*[T](self:CSet[T]):CSetIter[T]{.importcpp: "#.end()", nodecl.}
proc End*[T](self:CMultiSet[T]):CMultiSetIter[T]{.importcpp: "#.end()", nodecl.}
proc `*`*[T](self: SomeSetIter[T]):T{.importcpp: "*#", nodecl.}
proc `++`*[T](self:var SomeSetIter[T]){.importcpp: "++#", nodecl.}
proc `--`*[T](self:var SomeSetIter[T]){.importcpp: "--#", nodecl.}
proc `==`*[T](x,y:SomeSetIter[T]):bool{.importcpp: "(#==#)", nodecl.}
proc `==`*[T](x,y:SomeSet[T]):bool{.importcpp: "(#==#)", nodecl.}
proc distance*[T](x,y:SomeSetIter[T]):int{.importcpp: "distance(#,#)", nodecl.}
import sequtils # nim alias
proc add*[T](self:var SomeSet[T],x:T) = self.insert(x)
proc len*[T](self:SomeSet[T]):int = self.size()
proc min*[T](self:SomeSet[T]):T = *self.begin()
proc max*[T](self:SomeSet[T]):T = (var e = self.End();--e; *e)
proc contains*[T](self:SomeSet[T],x:T):bool = self.find(x) != self.End()
iterator items*[T](self:SomeSet[T]) : T =
  var (a,b) = (self.Begin(),self.End())
  while a != b : yield *a; ++a
proc `>`*[T](self:SomeSet[T],x:T) : seq[T] =
  var (a,b) = (self.upper_bound(x),self.End())
  result = @[]; while a != b :result .add *a; ++a
proc `>=`*[T](self:SomeSet[T],x:T) : seq[T] =
  var (a,b) = (self.lower_bound(x),self.End())
  result = @[]; while a != b :result .add *a; ++a
proc toSet*[T](arr:openArray[T]): CSet[T] = (result = initSet[T]();for a in arr: result.add(a))
proc toMultiSet*[T](arr:openArray[T]): CMultiSet[T] = (result = initMultiSet[T]();for a in arr: result.add(a))
proc toSeq[T](self:SomeSet[T]):seq[T] = self.mapIt(it)
proc `$`*[T](self:SomeSet[T]): string = $self.mapIt(it)
#}}}
