import
  json,
  nre,
  os,
  sequtils,
  streams,
  strutils,
  tables

import
  yaml,
  yaml/parser,
  yaml/tojson

import
  types


const HomeDirPath = getHomeDir()


const DataUnits = (
  byte: "B",
  kibibyte: "KiB",
  mebibyte: "MiB",
  gibibyte: "GiB",
)


type RuleYaml* = object
  path*: string
  ignores* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  itemTypes* {.defaultVal: none(seq[ItemType]).}: Option[seq[ItemType]]
  itemFullname* {.defaultVal: none(string).}: Option[string]
  itemFullnames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  itemName* {.defaultVal: none(string).}: Option[string]
  itemNames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  ext* {.defaultVal: none(string).}: Option[string]
  exts* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  itemSize* {.defaultVal: none(string).}: Option[string]
  fileFullname* {.defaultVal: none(string).}: Option[string]
  fileFullnames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  fileName* {.defaultVal: none(string).}: Option[string]
  fileNames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  fileSize* {.defaultVal: none(string).}: Option[string]
  dirName* {.defaultVal: none(string).}: Option[string]
  dirNames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  dirSize* {.defaultVal: none(string).}: Option[string]


type SettingYaml* = object
  ignores*: seq[string]
  regulations*: seq[RuleYaml]


func parseSize*(size: string): Size =
  let rawSize = size.split(re"(<=|>=|<|>|\d+)").filterIt(it != "")
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


func unexpandTilde(path, homeDirPath: string, dirSep: char): string =
  # If the homeDirPath is empty, return it as is
  if homeDirPath == "":
    return path
  # Remove trailing directory separator if present
  let trimmedHomeDirPath =
    if homeDirPath.endsWith(dirSep):
      homeDirPath[0..^2]
    else:
      homeDirPath
  let resultTemp = path.replace(re("^" & trimmedHomeDirPath), "~")
  return
    if resultTemp == "~": resultTemp & dirSep
    else: resultTemp


func unexpandTilde*(path: string): string =
  unexpandTilde(path, HomeDirPath, DirSep)
