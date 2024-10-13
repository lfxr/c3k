import
  unittest

import
  ../../../src/c3k/scan


check isIgnore("desktop.ini", @["desktop.ini"])
check not isIgnore("desktop.ini", @["lock"])

check isIgnore("cache", @["cache"])
check isIgnore("cache", @["bin", "cache"])

check not isIgnore("", @[".lock"])
check not isIgnore("", @[".lock"])

check not isIgnore("", @[])
