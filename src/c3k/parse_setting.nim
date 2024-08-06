import
  nre,
  os,
  sequtils,
  strutils

import
  types


const HomeDirPath = getHomeDir()


const DataUnits = (
  byte: "B",
  kibibyte: "KiB",
  mebibyte: "MiB",
  gibibyte: "GiB",
)


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


func unexpandTilde*(path: string): string =
  return path.replace(re("^" & HomeDirPath), "~" & DirSep)
