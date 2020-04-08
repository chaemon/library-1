# multisolution {{{
import streams

const CHECK = false

when CHECK:
  var output = newStringStream()
  print = proc(x: varargs[string,toStr]) = output.write(print0(@x,sep = " "))
  proc check() =
    output.flush()
    output.setPosition(0)
    # write check code
    stderr.write output.readAll()
  main()
  check()
else:
  main()
# }}}
