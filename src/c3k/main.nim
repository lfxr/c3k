import
  json,
  nre,
  options,
  os,
  sequtils,
  strutils,
  streams,
  tables

import
  yaml,
  yaml/parser,
  yaml/tojson

from glob import walkGlob

import
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


proc loadJson*(path: string): JsonNode =
  newFileStream(path).loadToJson[0]


proc parseSettingYaml*(settingYaml: SettingYaml): Setting =
  let rules: seq[Rule] = settingYaml.rules.mapIt(
    (
      path: it.path,
      itemTypes: it.itemTypes,
      itemFullname: it.itemFullname,
      itemName: it.itemName,
      ext: it.ext,
      itemSize:
        if it.itemSize.isSome: some(it.itemSize.get.parseSize)
        else: none(Size),
    )
  )
  return Setting(
    ignores: settingYaml.ignores,
    rules: rules,
  )


proc parseSettingJson*(settingJson: JsonNode): Setting =
  func generateRule(ruleJson: JsonNode): Option[string] =
    if ruleJson != nil:
      some(ruleJson.getStr)
    else:
      none(string)
  func generateSizeRule(ruleJson: JsonNode): Option[Size] =
    if ruleJson != nil:
      some(ruleJson.getStr.parseSize)
    else:
      none(Size)
  func generateTypesRule(ruleJson: JsonNode): Option[seq[ItemType]] =
    if ruleJson == nil:
      none(seq[ItemType])
    else:
      ## TODO: error handling
      some ruleJson.getElems.mapIt((
        case it.getStr:
          of "file": file
          of "dir": dir
          else: file
      ))

  let rulesJson = settingJson["rules"]
  var rules: seq[Rule] = @[]
  for key in rulesJson.getFields.keys:
    let ruleJson = rulesJson[key]
    rules.add (
      path: key,
      itemTypes: generateTypesRule(ruleJson{"itemTypes"}),
      itemFullname: generateRule(ruleJson{"itemFullname"}),
      itemName: generateRule(ruleJson{"itemName"}),
      ext: generateRule(ruleJson{"ext"}),
      itemSize: generateSizeRule(ruleJson{"itemSize"}),
    )
      
  return Setting(
    ignores: settingJson["ignores"].getElems.mapIt(it.getStr),
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


proc scan(item: Item, rule: Rule): seq[ScanningFailureReason] =
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


proc scan*(
    setting: Setting,
    workingDirPath: string,
    unexpandTilde: bool = true,
    fn: proc()
): ScanResult =
  result.succeeded = true

  setCurrentDir(workingDirPath)
  for rule in setting.rules:
    let matchedPathsByGlob =
      walkGlob(rule.path).toSeq.mapIt(it.splitFile.dir).deduplicate
    let matchedPaths =
      if matchedPathsByGlob.len == 0: walkPattern(rule.path).toSeq
      else: matchedPathsByGlob
    for matchedPath in matchedPaths:
      for item in walkDir(matchedPath):
        result.totalItems += 1
        if isIgnore(item.path.relativePath(matchedPath), setting.ignores):
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
