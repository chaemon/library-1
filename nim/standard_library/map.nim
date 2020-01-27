# map and multimap library from C++ {{{
type CMap {.importcpp: "std::map", header: "<map>".} [T,U] = object
type CMapIter {.importcpp: "std::map<'0,'1>::iterator", header: "<map>".} [T,U] = object
proc cInitMap(T, U: typedesc): CMap[T,U] {.importcpp: "std::map<'*1,'*2>()", nodecl.}
proc initMap*[T,U](): CMap[T,U] = cInitMap(T, U)

type CMultiMap {.importcpp: "std::multimap", header: "<map>".} [T,U] = object
type CMultiMapIter {.importcpp: "std::multimap<'0,'1>::iterator", header: "<map>".} [T,U] = object
proc cInitMultiMap(T, U: typedesc): CMultiMap[T,U] {.importcpp: "std::multimap<'*1,'*2>()", nodecl.}
proc initMultiMap*[T,U](): CMultiMap[T,U] = cInitMultiMap(T, U)

type
  SomeMap[T,U] = CMap[T,U]|CMultiMap[T,U]
  SomeMapIter[T,U] = CMapIter[T,U]|CMultiMapIter[T,U]

proc insert*[T,U](self: var SomeMap[T,U],x:T,y:U) {.importcpp: "#.insert(std::make_pair(#,#))", nodecl.}
proc `[]=`[T,U](self: var CMap[T,U], x:T, y:U) {.importcpp: "#[#] = #", nodecl.}
proc `[]`[T,U](self: var CMap[T,U], x:T):var U {.importcpp: "#[#]", nodecl.}
proc empty*[T,U](self: SomeMap[T,U]):bool {.importcpp: "#.empty()", nodecl.}
proc size*[T,U](self: SomeMap[T,U]):int {.importcpp: "#.size()", nodecl.}
proc clear*[T,U](self:var SomeMap[T,U]) {.importcpp: "#.clear()", nodecl.}
proc erase*[T,U](self: var SomeMap[T,U],x:T) {.importcpp: "#.erase(@)", nodecl.}
proc erase*[T,U](self: var SomeMap[T,U],x:SomeMapIter[T,U]) {.importcpp: "#.erase(@)", nodecl.}
proc find*[T,U](self: SomeMap[T,U],x:T): SomeMapIter[T,U] {.importcpp: "#.find(#)", nodecl.}
proc lowerBound*[T,U](self: CMap[T,U],x:T): CMapIter[T,U] {.importcpp: "#.lower_bound(#)", nodecl.}
proc lowerBound*[T,U](self: CMultiMap[T,U],x:T): CMultiMapIter[T,U] {.importcpp: "#.lower_bound(#)", nodecl.}
proc upperBound*[T,U](self: CMap[T,U],x:T): CMapIter[T,U] {.importcpp: "#.upper_bound(#)", nodecl.}
proc upperBound*[T,U](self: CMultiMap[T,U],x:T): CMultiMapIter[T,U] {.importcpp: "#.upper_bound(#)", nodecl.}
proc Begin*[T,U](self:CMap[T,U]):CMapIter[T,U]{.importcpp: "#.begin()", nodecl.}
proc Begin*[T,U](self:CMultiMap[T,U]):CMultiMapIter[T,U]{.importcpp: "#.begin()", nodecl.}
proc End*[T,U](self:CMap[T,U]):CMapIter[T,U]{.importcpp: "#.end()", nodecl.}
proc End*[T,U](self:CMultiMap[T,U]):CMultiMapIter[T,U]{.importcpp: "#.end()", nodecl.}
proc `*`*[T,U](self: SomeMapIter[T,U]):T{.importcpp: "*#", nodecl.}
proc `++`*[T,U](self:var SomeMapIter[T,U]){.importcpp: "++#", nodecl.}
proc `--`*[T,U](self:var SomeMapIter[T,U]){.importcpp: "--#", nodecl.}
proc `==`*[T,U](x,y:SomeMapIter[T,U]):bool{.importcpp: "(#==#)", nodecl.}
proc `==`*[T,U](x,y:SomeMap[T,U]):bool{.importcpp: "(#==#)", nodecl.}
proc first*[T,U](self:SomeMapIter[T,U]):T {.importcpp: "#->first", nodecl.}
proc second*[T,U](self:SomeMapIter[T,U]):U {.importcpp: "#->second", nodecl.}
proc distance*[T,U](x,y:SomeMapIter[T,U]):int{.importcpp: "distance(#,#)", nodecl.}
import sequtils # nim alias
proc add*[T,U](self:var SomeMap[T,U], x:T, y:U) = self.insert(x,y)
proc len*[T,U](self:SomeMap[T,U]):int = self.size()
proc min*[T,U](self:SomeMap[T,U]):T = *self.Begin()
proc max*[T,U](self:SomeMap[T,U]):T = (var e = self.End();--e; *e)
proc key*[T,U](self:SomeMapIter[T,U]):T = self.first
proc value*[T,U](self:SomeMapIter[T,U]):U = self.second
proc contains*[T,U](self:SomeMap[T,U],x:T):bool = self.find(x) != self.End()
iterator items*[T,U](self:CMap[T,U]) : CMapIter[T,U] =
  var (a,b) = (self.Begin(),self.End())
  while a != b : yield a; ++a
iterator items*[T,U](self:CMultiMap[T,U]) : CMultiMapIter[T,U] =
  var (a,b) = (self.Begin(),self.End())
  while a != b : yield a; ++a
proc `>`*[T,U](self:SomeMap[T,U],x:T) : seq[T] =
  var (a,b) = (self.upper_bound(x),self.End())
  result = @[]; while a != b :result .add *a; ++a
proc `>=`*[T,U](self:SomeMap[T,U],x:T) : seq[T] =
  var (a,b) = (self.lower_bound(x),self.End())
  result = @[]; while a != b :result .add *a; ++a
template toMap*(arr:openArray): CMap =
  var res = cInitMap(arr[0][0].type,arr[0][1].type)
  for a in arr:
    res.add(a[0],a[1])
  res
proc toMultiMap*[T,U](arr:openArray[(T,U)]): CMultiMap[T,U] = (result = cInitMultiMap(T,U);for a in arr: result.add(a[0],a[1]))
proc toSeq[T,U](self:SomeMap[T,U]):seq[(T,U)] =
  result = newSeq[(T,U)]()
  for it in self.items:
    result.add((it.key, it.value))
proc `$`*[T,U](self:SomeMap[T,U]): string = $self.toSeq()
#}}}
