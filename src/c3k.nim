import
  os

import
  m17n,
  messages,
  types,
  c3k/main,
  c3k/scan_result


let appDirPath = getConfigDir() / "c3k"
let settingFilePath = appDirPath / "c3k.setting.yaml"
let m17nEcho = m17nEcho(ja_JP)


proc initCommand(args: seq[string]) =
  m17nEcho multiLangMessages.startingInitialization
  # アプリディレクトリが存在しない場合は作成する
  if not appDirPath.dirExists:
    m17nEcho multiLangMessages.creatingAppDirectory
    createDir appDirPath
  # 設定ファイルが存在しない場合は作成する
  if not settingFilePath.fileExists:
    m17nEcho multiLangMessages.creatingSettingFile
    let settingFile = open(settingFilePath, fmWrite)
    defer: settingFile.close()
    settingFile.write("")
    m17nEcho multiLangMessages.settingFileCreated
  m17nEcho multiLangMessages.initializationFinished


proc scanCommand(args: seq[string]) =
  let settingFilePath = "src/.c3k.yaml"
  m17nEcho multiLangMessages.usingXAsASettingFile(settingFilePath)
  m17nEcho multiLangMessages.loadingAndParsingSettingFile
  let settingYaml = loadYaml(settingFilePath)
  let setting = parseSettingsYaml(settingYaml)
  let scanResult = scan(setting, appDirPath, proc()=discard)
  m17nEcho multiLangMessages.scanFinishedSuccessfuly
  m17nEcho multiLangMessages.XImproperItemsOutOfYItemFound(
    scanResult.failedItems.len, 0
  )
  # m17nEcho multiLangMessages.scanResult(scanResult)
  echo scanResult.format


when isMainModule:
  import cligen
  dispatchMulti(
    [initCommand, cmdName="init"],
    [scanCommand, cmdName="scan"],
  )
