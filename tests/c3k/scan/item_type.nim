import
  os,
  unittest

import
  ../../../src/c3k/scan,
  ../../../src/c3k/types


check (kind: pcFile, path: "").itemType == file
check (kind: pcFile, path: "foo").itemType == file

check (kind: pcDir, path: "").itemType == dir
check (kind: pcDir, path: "foo").itemType == dir
