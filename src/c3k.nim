import
  os

import
  m17n,
  messages,
  types,
  c3k/main,
  c3k/scan_result


let c3kDirPath = getConfigDir() / "c3k"
let settingFilePath = c3kDirPath / "c3k.setting.yaml"


proc initCommand(args: seq[string]) =
  if not c3kDirPath.dirExists:
    createDir c3kDirPath
  if not settingFilePath.fileExists:
    let settingFile = open(settingFilePath, fmWrite)
    defer: settingFile.close()
    settingFile.write("")


proc scanCommand(args: seq[string]) =
  let m17nEcho = m17nEcho(ja_JP)
  let settingFilePath = "src/.c3k.yaml"
  m17nEcho multiLangMessages.usingXAsASettingFile(settingFilePath)
  m17nEcho multiLangMessages.loadingAndParsingSettingFile
  let settingYaml = loadYaml(settingFilePath)
  let setting = parseSettingsYaml(settingYaml)
  let scanResult = scan(setting, proc()=discard)
  m17nEcho multiLangMessages.scanFinishedSuccessfuly
  # m17nEcho multiLangMessages.scanResult(scanResult)
  echo scanResult.format


when isMainModule:
  import cligen
  dispatchMulti(
    [initCommand, cmdName="init"],
    [scanCommand, cmdName="scan"],
  )
