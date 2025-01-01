import
  unittest

import
  ../../../src/c3k/utils/item {.all.}


# subExt
block:
  check subExt("") == ""
  check subExt("foo") == ""
  check subExt(".") == "."
  check subExt("foo.e.js") == ".e.js"
  check subExt(".e.js") == ".e.js"
  check subExt("foo.bar.baz") == ".bar.baz"
