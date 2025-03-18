import
  os,
  sequtils

import
  ../types,
  path


proc newItem*(path: string): Item =
  result.path = path
  result.metadata = path.metadata


proc childItems*(item: Item): seq[Item] =
  walkDir(item.path).toSeq.mapIt(newItem(it.path))
