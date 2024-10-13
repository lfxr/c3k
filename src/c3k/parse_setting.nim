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
