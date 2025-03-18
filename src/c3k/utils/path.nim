import
  os,
  sequtils,
  strutils

import
  regex

from glob import walkGlob

import
  ../types


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
  let resultTemp = path.replace(re2("^" & trimmedHomeDirPath), "~")
  return
    if resultTemp == "~": resultTemp & dirSep
    else: resultTemp


func unexpandTilde*(path: string): string =
  unexpandTilde(path, getHomeDir(), DirSep)


proc matchingPaths*(path: string): seq[string] =
  if path.contains("*"):
    walkGlob(path).toSeq
  else:
    @[path]


proc itemKind(path: string): ItemKind =
  if path.fileExists: file
  elif path.dirExists: dir
  else: none


proc exists(path: string): bool =
  path.itemKind != none


func subExt(path: string): string =
  const DOT = '.'
  if DOT in path:
    DOT & path.split(DOT, maxsplit=1)[^1]
  else: ""


proc metadata*(path: string): ItemMetadata =
  (
    exists: path.exists,
    kind: path.itemKind,
    fullName: path.splitFile.name,
    name: path.splitFile.name & path.splitFile.ext,
    ext: path.splitFile.ext,
    subExt: path.subExt,
  )
