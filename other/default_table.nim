# default-table {{{
import tables

proc `[]`[A, B](self: var Table[A, B], key: A): var B =
  discard self.hasKeyOrPut(key, B.default)
  tables.`[]`(self, key)
#}}}
