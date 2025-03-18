import
  json,
  sequtils,
  streams,
  strutils,
  tables

import
  regex,
  yaml,
  yaml/tojson

import
  types


const DataUnits = (
  byte: "B",
  kibibyte: "KiB",
  mebibyte: "MiB",
  gibibyte: "GiB",
)


func parseSize*(size: string): Size =
  let rawSize = size.split(re2"(<=|>=|<|>|\d+)").filterIt(it != "")
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


proc loadJson*(path: string): JsonNode =
  newFileStream(path).loadToJson[0]


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
  func generateExistenceRule(ruleJson: JsonNode): Option[Existence] =
    if ruleJson == nil:
      none(Existence)
    else:
      some(
        case ruleJson.getStr:
          of "required": Existence.required
          of "disallowed": Existence.disallowed
          else: required
      )
  func generatekindsRule(ruleJson: JsonNode): Option[seq[ItemKind]] =
    if ruleJson == nil:
      none(seq[ItemKind])
    else:
      ## TODO: error handling
      some ruleJson.getElems.mapIt((
        case it.getStr:
          of "file": file
          of "dir": dir
          else: none
      ))
  func generateIntRule(ruleJson: JsonNode): Option[int] =
    if ruleJson == nil:
      none(int)
    else:
      some ruleJson.getInt
  func generateFinalNewLineRule(ruleJson: JsonNode): Option[FinalNewLine] =
    if ruleJson == nil:
      none(FinalNewLine)
    else:
      some(
        case ruleJson.getStr:
          of "required": FinalNewLine.required
          of "disallowed": FinalNewLine.disallowed
          else: required
      )

  let rulesJson = settingJson["regulations"]
  var regulations: seq[Regulation] = @[]
  for key in rulesJson.getFields.keys:
    let
      ruleJson: JsonNode = rulesJson[key]
      ruleSelfJson: JsonNode = ruleJson["self"]
      ruleChildJson: JsonNode = ruleJson["child"]
    regulations.add (
      path: key,
      ignores: generateIgnoresRule(ruleJson{"ignores"}),
      rules: (
        selfRules: (
          itemMetadata: (
            existence:        generateExistenceRule(ruleSelfJson{"existence"}),
            childItemsNumber: generateIntRule(ruleSelfJson{"childItemsNumber"}),
            kinds:            generatekindsRule(ruleSelfJson{"kinds"}),
            itemFullname:     generateRule(ruleSelfJson{"itemFullname"}),
            itemFullnames:    generateStringSeqRule(ruleSelfJson{"itemFullnames"}),
            itemName:         generateRule(ruleSelfJson{"itemName"}),
            itemNames:        generateStringSeqRule(ruleSelfJson{"itemNames"}),
            ext:              generateRule(ruleSelfJson{"ext"}),
            exts:             generateStringSeqRule(ruleSelfJson{"exts"}),
            subExt:           generateRule(ruleSelfJson{"subExt"}),
            subExts:          generateStringSeqRule(ruleSelfJson{"subExts"}),
            itemSize:         generateSizeRule(ruleSelfJson{"itemSize"}),
            fileFullname:     generateRule(ruleSelfJson{"fileFullname"}),
            fileFullnames:    generateStringSeqRule(ruleSelfJson{"fileFullnames"}),
            fileName:         generateRule(ruleSelfJson{"fileName"}),
            fileNames:        generateStringSeqRule(ruleSelfJson{"fileNames"}),
            fileSize:         generateSizeRule(ruleSelfJson{"fileSize"}),
            dirName:          generateRule(ruleSelfJson{"dirName"}),
            dirNames:         generateStringSeqRule(ruleSelfJson{"dirNames"}),
            dirSize:          generateSizeRule(ruleSelfJson{"dirSize"}),
          ),
          itemData: (
            finalNewLine:     generateFinalNewLineRule(ruleSelfJson{"finalNewLine"}),
          ),
        ),
        childItemsRules: (
          itemMetadata: (
            existence:        generateExistenceRule(ruleChildJson{"existence"}),
            childItemsNumber: generateIntRule(ruleChildJson{"childItemsNumber"}),
            kinds:            generateKindsRule(ruleChildJson{"kinds"}),
            itemFullname:     generateRule(ruleChildJson{"itemFullname"}),
            itemFullnames:    generateStringSeqRule(ruleChildJson{"itemFullnames"}),
            itemName:         generateRule(ruleChildJson{"itemName"}),
            itemNames:        generateStringSeqRule(ruleChildJson{"itemNames"}),
            ext:              generateRule(ruleChildJson{"ext"}),
            exts:             generateStringSeqRule(ruleChildJson{"exts"}),
            subExt:           generateRule(ruleChildJson{"subExt"}),
            subExts:          generateStringSeqRule(ruleChildJson{"subExts"}),
            itemSize:         generateSizeRule(ruleChildJson{"itemSize"}),
            fileFullname:     generateRule(ruleChildJson{"fileFullname"}),
            fileFullnames:    generateStringSeqRule(ruleChildJson{"fileFullnames"}),
            fileName:         generateRule(ruleChildJson{"fileName"}),
            fileNames:        generateStringSeqRule(ruleChildJson{"fileNames"}),
            fileSize:         generateSizeRule(ruleChildJson{"fileSize"}),
            dirName:          generateRule(ruleChildJson{"dirName"}),
            dirNames:         generateStringSeqRule(ruleChildJson{"dirNames"}),
            dirSize:          generateSizeRule(ruleChildJson{"dirSize"}),
          ),
          itemData: (
            finalNewLine:     generateFinalNewLineRule(ruleChildJson{"finalNewLine"}),
          ),
        ),
      ),
    )

  return Setting(
    ignores: settingJson["ignores"].getElems.mapIt(it.getStr),
    regulations: regulations,
  )
