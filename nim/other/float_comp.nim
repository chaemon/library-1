# float comp {{{
const EPS = 1e-9

proc `==`(a,b:float):bool = system.`<`(abs(a - b), EPS)
proc `!=`(a,b:float):bool = system.`>`(abs(a - b), EPS)
proc `<`(a,b:float):bool = system.`<`(a + EPS, b)
proc `>`(a,b:float):bool = system.`>`(a, b + EPS)
proc `<=`(a,b:float):bool = system.`<`(a, b + EPS)
proc `>=`(a,b:float):bool = system.`>`(a + EPS, b)
# }}}
