# Interactive {{{
const CHECK = false

when CHECK:
  type Interactive = object
    ans: string
    time, limit: int
#  var interactive = Interactive(ans: "RRBBRB", time: 0, limit: 210)
  var interactive = Interactive(ans: "RBBRBRBRBRRBBR", time: 0, limit: 210)
  N = interactive.ans.len div 2

  import streams
  
#  var output = newStringStream()
  var output = initDeque[string]()
  print = proc(x: varargs[string,toStr]) = output.addLast(print0(@x,sep = " "))

  proc ask(self: var Interactive):string = 
    self.time += 1
    var s = output.popFirst().strip()
    stderr.write "time: ", self.time, " query: ", s, "\n"
    if self.time > self.limit: 
      stderr.write "too many query!!"
      assert(false)
    v := s[2..^1].split(" ").mapIt(it.parseInt - 1)
    var
      R = 0
      B = 0
    for i in v:
      if self.ans[i] == 'R': R += 1
      else: B += 1
    if R > B: result = "Red"
    else: result = "Blue"
    stderr.write "                    ", result, "\n"
  proc judge(self: var Interactive) =
    let s = output.popFirst().strip()
    stderr.write "judge: ", s, "\n"
    assert(s[2..^1] == interactive.ans)

proc ask(v:seq[int]):int =
  print "?", v.mapIt($(it + 1)).join(" ")
  let T = when CHECK: interactive.ask() else: nextString()
  if T == "Red": return 0
  elif T == "Blue": return 1

proc judge(s:string) =
  print "!", s
  when CHECK: interactive.judge()
# }}}

