import
  os

import
  m17n,
  messages,
  types,
  c3k/main,
  c3k/scan_result


const mlm = multiLangMessages
let
  appDirPath = getConfigDir() / "c3k"
  settingFilePath = appDirPath / "c3k.setting.yaml"
  m17nEcho = m17nEcho(ja_JP)


proc initCommand(args: seq[string]) =
  m17nEcho mlm.startingInitialization

  # アプリディレクトリが存在しない場合は作成する
  if not appDirPath.dirExists:
    m17nEcho mlm.creatingAppDirectory
    createDir appDirPath

  # 設定ファイルが存在しない場合は作成する
  if not settingFilePath.fileExists:
    m17nEcho mlm.creatingSettingFile
    let settingFile = open(settingFilePath, fmWrite)
    defer: settingFile.close()
    try:
      settingFile.write("")
    except:
      m17nEcho mlm.failedToCreateSettingFile
      return
    m17nEcho mlm.settingFileCreated
  m17nEcho mlm.initializationFinished


proc scanCommand(args: seq[string]) =
  let settingFilePath = "src/.c3k.yaml"
  if not settingFilePath.fileExists:
    m17nEcho mlm.noSettingFileDetected
    return
  m17nEcho mlm.usingXAsASettingFile(settingFilePath)
  m17nEcho mlm.loadingAndParsingSettingFile
  let settingYaml = loadYaml(settingFilePath)
  let setting = parseSettingsYaml(settingYaml)

  let scanResult = scan(setting, appDirPath, fn=proc()=discard)
  m17nEcho mlm.scanFinishedSuccessfuly
  if not scanResult.succeeded:
    m17nEcho mlm.XImproperItemsOutOfYItemFound(
      scanResult.failedItems.len, scanResult.totalItems
    )
    # m17nEcho mlm.scanResult(scanResult)
    echo scanResult.format


when isMainModule:
  import cligen
  dispatchMulti(
    [initCommand, cmdName="init"],
    [scanCommand, cmdName="scan"],
  )
