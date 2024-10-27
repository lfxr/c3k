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
  let regulations: seq[Regulation] = settingYaml.regulations.mapIt(
    (
      path: it.path,
      ignores: it.ignores,
      rules: (
        currentDir: "",
        childItems: (
          itemTypes: it.itemTypes,
          itemFullname: it.itemFullname,
          itemFullnames: it.itemFullnames,
          itemName: it.itemName,
          itemNames: it.itemNames,
          ext: it.ext,
          exts: it.exts,
          itemSize:
            if it.itemSize.isSome: some(it.itemSize.get.parseSize)
            else: none(Size),
          fileFullname: it.fileFullname,
          fileFullnames: it.fileFullnames,
          fileName: it.fileName,
          fileNames: it.fileNames,
          fileSize:
            if it.fileSize.isSome: some(it.fileSize.get.parseSize)
            else: none(Size),
          dirName: it.dirName,
          dirNames: it.dirNames,
          dirSize:
            if it.dirSize.isSome: some(it.dirSize.get.parseSize)
            else: none(Size),
        ),
      ),
    )
  )
  return Setting(
    ignores: settingYaml.ignores,
    regulations: regulations,
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
  func generateStringSeqRule(ruleJson: JsonNode): Option[seq[string]] =
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

  let rulesJson = settingJson["regulations"]
  var regulations: seq[Regulation] = @[]
  for key in rulesJson.getFields.keys:
    let ruleJson = rulesJson[key]
    regulations.add (
      path: key,
      ignores: generateIgnoresRule(ruleJson{"ignores"}),
      rules: (
        currentDir: "",
        childItems: (
          itemTypes: generateTypesRule(ruleJson{"itemTypes"}),
          itemFullname: generateRule(ruleJson{"itemFullname"}),
          itemFullnames: generateStringSeqRule(ruleJson{"itemFullnames"}),
          itemName: generateRule(ruleJson{"itemName"}),
          itemNames: generateStringSeqRule(ruleJson{"itemNames"}),
          ext: generateRule(ruleJson{"ext"}),
          exts: generateStringSeqRule(ruleJson{"exts"}),
          itemSize: generateSizeRule(ruleJson{"itemSize"}),
          fileFullname: generateRule(ruleJson{"fileFullname"}),
          fileFullnames: generateStringSeqRule(ruleJson{"fileFullnames"}),
          fileName: generateRule(ruleJson{"fileName"}),
          fileNames: generateStringSeqRule(ruleJson{"fileNames"}),
          fileSize: generateSizeRule(ruleJson{"fileSize"}),
          dirName: generateRule(ruleJson{"dirName"}),
          dirNames: generateStringSeqRule(ruleJson{"dirNames"}),
          dirSize: generateSizeRule(ruleJson{"dirSize"}),
        ),
      ),
    )
      
  return Setting(
    ignores: settingJson["ignores"].getElems.mapIt(it.getStr),
    regulations: regulations,
  )


proc scan*(
    setting: Setting,
    workingDirPath: string,
    unexpandTilde: bool = true,
    fn: proc()
): ScanResult =
  setCurrentDir(workingDirPath)
  for regulation in setting.regulations:
    let matchedPathsByGlob =
      walkGlob(regulation.path).toSeq.mapIt(it.splitFile.dir).deduplicate
    let matchedPaths =
      if matchedPathsByGlob.len == 0: walkPattern(regulation.path).toSeq
      else: matchedPathsByGlob
    for matchedPath in matchedPaths:
      for item in walkDir(matchedPath):
        result.scannedItemsNumber += 1
        if isIgnore(item.path.relativePath(matchedPath), setting.ignores):
          continue

        if isIgnore(
          item.path.relativePath(matchedPath),
          if regulation.ignores.isSome: regulation.ignores.get
          else: @[],
        ):
          continue

        let scanningFailureReasons = item.scan(regulation)
        if scanningFailureReasons.len == 0:
          continue

        result.violationItems.add((
          path:
            if unexpandTilde: item.path.unexpandTilde
            else: item.path,
          itemType: item.itemType,
          violations: scanningFailureReasons,
        ))
