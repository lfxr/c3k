import
  nre,
  sequtils,
  strutils,
  streams

import
  yaml

import
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


proc loadYaml*(filePath: string): SettingsYaml = 
  var s = newFileStream(filePath)
  load(s, result)
  s.close()


func parseSettingsYaml*(settingsYaml: SettingsYaml): Settings =
  let rules: seq[Rule] = settingsYaml.rules.mapIt(
    (
      path: it.path,
      itemTypes: it.itemTypes,
      itemFullname: it.itemFullname,
      itemName: it.itemName,
      itemExt: it.itemExt,
      itemSize: it.itemSize.parseSize,
    )
  )
  return Settings(
    ignores: settingsYaml.ignores,
    rules: rules,
  )


func scan*(settings: string, fn: proc()) =
  discard
