import
  nre,
  os,
  strutils


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
  unexpandTilde(path, getHomeDir(), DirSep)
