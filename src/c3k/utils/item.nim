import
  os,
  strutils

import
  ../types


func subExt(path: string): string =
  const DOT = '.'
  if DOT in path:
    DOT & path.split(DOT, maxsplit=1)[^1]
  else: ""


func itemType*(item: Item): ItemType =
  if item.kind == pcFile: file
  else: dir


type ItemMetaData* = tuple[
  path: string,
  itemType: ItemType, 
  ext: string,
  subExt: string,
]


func metaData*(item: Item): ItemMetaData =
  (
    path: item.path,
    itemType: itemType(item),
    ext: item.path.splitFile.ext,
    subExt: item.path.subExt,
  )
