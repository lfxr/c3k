import
  unittest

import
  ../../../src/c3k/scan


check isIgnore("desktop.ini", @["desktop.ini"])
check isIgnore("", @[".lock"])
check isIgnore("", @[".lock"])

check isIgnore("", @[])
