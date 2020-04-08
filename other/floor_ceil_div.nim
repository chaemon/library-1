#{{{ floorDiv and CeilDiv
proc ceilDiv(a,b:int):int =
  assert(b > 0)
  result = a div b
  let r = a mod b
  if r != 0 and a > 0: result += 1
proc floorDiv(a,b:int):int =
  assert(b > 0)
  result = a div b
  let r = a mod b
  if r != 0 and a < 0: result -= 1
#}}}
