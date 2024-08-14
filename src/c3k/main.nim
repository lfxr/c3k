import
  json,
  nre,
  options,
  os,
  sequtils,
  streams,
  tables

import
  yaml,
  yaml/parser,
  yaml/tojson

from glob import walkGlob

import
  parse_setting,
  scan,
  types


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
      ignores: it.ignores,
      itemTypes: it.itemTypes,
      itemFullname: it.itemFullname,
      itemName: it.itemName,
      ext: it.ext,
      itemSize:
        if it.itemSize.isSome: some(it.itemSize.get.parseSize)
        else: none(Size),
      fileFullname: it.fileFullname,
      fileName: it.fileName,
      fileSize:
        if it.fileSize.isSome: some(it.fileSize.get.parseSize)
        else: none(Size),
      dirName: it.dirName,
      dirSize:
        if it.dirSize.isSome: some(it.dirSize.get.parseSize)
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
  func generateIgnoresRule(ruleJson: JsonNode): Option[seq[string]] =
    if ruleJson == nil:
      none(seq[string])
    else:
      some ruleJson.getElems.mapIt(it.getStr)
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
      ignores: generateIgnoresRule(ruleJson{"ignores"}),
      itemTypes: generateTypesRule(ruleJson{"itemTypes"}),
      itemFullname: generateRule(ruleJson{"itemFullname"}),
      itemName: generateRule(ruleJson{"itemName"}),
      ext: generateRule(ruleJson{"ext"}),
      itemSize: generateSizeRule(ruleJson{"itemSize"}),
      fileFullname: generateRule(ruleJson{"fileFullname"}),
      fileName: generateRule(ruleJson{"fileName"}),
      fileSize: generateSizeRule(ruleJson{"fileSize"}),
      dirName: generateRule(ruleJson{"dirName"}),
      dirSize: generateSizeRule(ruleJson{"dirSize"}),
    )
      
  return Setting(
    ignores: settingJson["ignores"].getElems.mapIt(it.getStr),
    rules: rules,
  )


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

        if isIgnore(
          item.path.relativePath(matchedPath),
          if rule.ignores.isSome: rule.ignores.get
          else: @[],
        ):
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
