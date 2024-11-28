import
  os

import
  ../types


func itemType*(item: Item): ItemType =
  if item.kind == pcFile: file
  else: dir


type ItemMetaData* = tuple[
  path: string,
  itemType: ItemType, 
  ext: string,
]


func metaData*(item: Item): ItemMetaData =
  (
    path: item.path,
    itemType: itemType(item),
    ext: item.path.splitFile.ext,
  )
