import
  nre,
  options,
  os,
  sequtils,
  strformat,
  strutils,
  streams

import
  yaml,
  yaml/parser

import
  ../types,
  types


const HomeDirPath = getHomeDir()
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


func unexpandTilde(path: string): string =
  return path.replace(re("^" & HomeDirPath), "~" & DirSep)


proc loadYaml*(filePath: string): SettingYaml =
  var s = newFileStream(filePath)
  try:
    load(s, result)
  except IOError, OSError:
    echo "o"
  except YamlConstructionError, YamlParserError:
    echo "p"
  s.close()


proc parseSettingsYaml*(settingYaml: SettingYaml): Setting =
  let rules: seq[Rule] = settingYaml.rules.mapIt(
    (
      path: it.path,
      itemTypes: it.itemTypes,
      itemFullname: it.itemFullname,
      itemName: it.itemName,
      itemExt: it.itemExt,
      itemSize:
        if it.itemSize.isSome: some(it.itemSize.get.parseSize)
        else: none(Size),
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
      failureReason: ScanningFailureReason.itemExt,
      result:
        if rule.itemExt.isSome:
          checkItemExt(itemExt, rule.itemExt.get)
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


proc scan*(
    setting: Setting,
    workingDirPath: string,
    unexpandTilde: bool = true,
    fn: proc()
): ScanResult =
  result.succeeded = true

  setCurrentDir(workingDirPath)
  for rule in setting.rules:
    for item in walkDir(rule.path.absolutePath):
      result.totalItems += 1
      if isIgnore(item.path, setting.ignores):
        continue

      let scanningFailureReasons = item.scan(rule)
      if scanningFailureReasons.len == 0:
        continue

      result.succeeded = false
      result.failedItems.add((
        itemPath:
          if unexpandTilde: item.path.unexpandTilde
          else: item.path,
        itemType: item.itemType,
        reasons: scanningFailureReasons,
      ))
