import
  nre,
  os,
  sequtils,
  strutils,
  streams

import
  yaml

import
  ../types,
  types


const DataUnits = (
  byte: "B",
  kibibyte: "KiB",
  mebibyte: "MiB",
  gibibyte: "GiB",
)


proc parseSize*(size: string): Size =
  let rawSize = size.split(re"(<|<=|>|>=|(\d|\.)+)").filterIt(it != "")
  result.comparisonOperator =
    case rawSize[0]:
    of $lessThan: lessThan
    of $lessThanOrEqual: lessThanOrEqual
    of $greaterThan: greaterThan
    of $greaterThanOrEqual: greaterThanOrEqual
    of $equal: equal
    else: equal
  result.size = rawSize[1].parseInt
  result.unit =
    case rawSize[2]:
    of DataUnits.byte: byte
    of DataUnits.kibibyte: kibibyte
    of DataUnits.mebibyte: mebibyte
    of DataUnits.gibibyte: gibibyte
    else: byte


proc loadYaml*(filePath: string): SettingYaml = 
  var s = newFileStream(filePath)
  load(s, result)
  s.close()


func parseSettingsYaml*(settingYaml: SettingYaml): Setting =
  let rules: seq[Rule] = settingYaml.rules.mapIt(
    (
      path: it.path,
      itemTypes: it.itemTypes,
      itemFullname: it.itemFullname,
      itemName: it.itemName,
      itemExt: it.itemExt,
      itemSize: it.itemSize.parseSize,
    )
  )
  return Setting(
    ignores: settingYaml.ignores,
    rules: rules,
  )


func find(target, pattern: string): bool =
  target.find(re(pattern)).isSome


func isIgnore(path: string, ignores: seq[string]): bool =
  ignores.filterIt(path.find(it)).len > 0


func itemType(item: Item): ItemType =
  if item.kind == pcFile: file
  else: dir


func checkItemType(itemType: ItemType, itemTypes: seq[ItemType]): bool =
  itemType in itemTypes


func checkItemFullname(itemFullname, pattern: string): bool =
  itemFullname.find(pattern)


func checkItemName(itemName, pattern: string): bool =
  itemName.find(pattern)


func checkItemExt(itemExt, pattern: string): bool =
  itemExt.find(pattern)


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


proc scan(item: Item, rule: Rule): seq[ScanningFailureReason] =
  let
    itemType = item.itemType
    itemFullname = item.path.extractFilename
    itemName =
      if itemType == file: item.path.splitFile.name
      else: item.path.lastPathPart
    itemExt = item.path.splitFile.ext
    itemSize = item.path.getFileSize

  return @[
    (
      failureReason: ScanningFailureReason.itemType,
      result: checkItemType(itemType, rule.itemTypes)
    ),
    (
      failureReason: ScanningFailureReason.itemFullname,
      result: checkItemFullname(itemFullname, rule.itemFullname)
    ),
    (
      failureReason: ScanningFailureReason.itemName,
      result: checkItemName(itemName, rule.itemName)
    ),
    (
      failureReason: ScanningFailureReason.itemExt,
      result: checkItemExt(itemExt, rule.itemExt)
    ),
    (
      failureReason: ScanningFailureReason.itemSize,
      result: checkItemSize(itemSize, rule.itemSize)
    )
  ].filterIt(not it.result).mapIt(it.failureReason)


proc scan*(setting: Setting, fn: proc()): ScanResult =
  result.succeeded = true

  for rule in setting.rules:
    for item in walkDir(rule.path.expandTilde):
      if isIgnore(item.path, setting.ignores):
        continue

      let scanningFailureReasons = item.scan(rule)
      if scanningFailureReasons.len == 0:
        continue

      result.succeeded = false
      result.failedItems.add((
        itemPath: item.path,
        itemType: item.itemType,
        reasons: scanningFailureReasons,
      ))
