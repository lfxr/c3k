import
  nre,
  options,
  os,
  sequtils

import
  types


func find(target, pattern: string): bool =
  target.find(re(pattern)).isSome


func isIgnore*(path: string, ignores: seq[string]): bool =
  ignores.filterIt(path.find(it)).len > 0


func itemType*(item: Item): ItemType =
  if item.kind == pcFile: file
  else: dir


func checkItemType(itemType: ItemType, itemTypes: seq[ItemType]): bool =
  itemType in itemTypes


func checkItemFullname(itemFullname, pattern: string): bool =
  itemFullname.find(pattern)


func checkItemName(itemName, pattern: string): bool =
  itemName.find(pattern)


func checkExt(ext, pattern: string): bool =
  ext.find(pattern)


func checkItemSize(actualSizeBytes: int, expectedSize: Size): bool =
  let comparisonFunc = func (a, b: int): bool =
    case expectedSize.comparisonOperator:
      of ComparisonOperator.lessThan:
        a < b
      of ComparisonOperator.lessThanOrEqual:
        a <= b
      of ComparisonOperator.greaterThan:
        a > b
      of ComparisonOperator.greaterThanOrEqual:
        a >= b
      of ComparisonOperator.equal:
        a == b
  return comparisonFunc(
    actualSizeBytes, expectedSize.size * expectedSize.unit.int
  )


proc scan*(item: Item, rule: Rule): seq[ScanningFailureReason] =
  let
    itemType = item.itemType
    itemFullname = item.path.extractFilename
    itemName =
      if itemType == file: item.path.splitFile.name
      else: item.path.lastPathPart
    ext = item.path.splitFile.ext
    itemSize = item.path.getFileSize
  return @[
    (
      failureReason: ScanningFailureReason.itemType,
      result:
        if rule.itemTypes.isSome: checkItemType(itemType, rule.itemTypes.get)
        else: true,
    ),
    (
      failureReason: ScanningFailureReason.itemFullname,
      result:
        if rule.itemFullname.isSome:
          checkItemFullname(itemFullname, rule.itemFullname.get)
        else: true,
    ),
    (
      failureReason: ScanningFailureReason.itemName,
      result:
        if rule.itemName.isSome:
          checkItemName(itemName, rule.itemName.get)
        else: true,
    ),
    (
      failureReason: ScanningFailureReason.ext,
      result:
        if itemType == file and rule.ext.isSome:
          checkExt(ext, rule.ext.get)
        else: true,
    ),
    (
      failureReason: ScanningFailureReason.itemSize,
      result:
        if rule.itemSize.isSome:
          checkItemSize(itemSize, rule.itemSize.get)
        else: true,
    )
  ].filterIt(not it.result).mapIt(it.failureReason)
