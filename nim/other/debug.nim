import macros

macro debug*(n: varargs[untyped]): untyped =
  result = newNimNode(nnkStmtList, n)
  for i,x in n:
    result.add(newCall("write", newIdentNode("stderr"), toStrLit(x)))
    result.add(newCall("write", newIdentNode("stderr"), newStrLitNode(" = ")))
    result.add(newCall("write", newIdentNode("stderr"), x))
    if i < n.len - 1: result.add(newCall("write", newIdentNode("stderr"), newStrLitNode(", ")))
  result.add(newCall("write", newIdentNode("stderr"), newStrLitNode("\n")))
