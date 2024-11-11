import
  os,
  times

import
  m17n,
  messages,
  scan_result,
  types,
  c3k/main


const mlm = multiLangMessages
let
  appDirPath = getConfigDir() / "c3k"
  settingFilePath = appDirPath / "c3k.setting.yaml"
  echo = echoM17n(ja_JP)


proc initCommand(args: seq[string]) =
  echo mlm.startingInitialization

  # アプリディレクトリが存在しない場合は作成する
  if not appDirPath.dirExists:
    echo mlm.creatingAppDirectory
    createDir appDirPath

  # 設定ファイルが存在しない場合は作成する
  if not settingFilePath.fileExists:
    echo mlm.creatingSettingFile
    let settingFile = open(settingFilePath, fmWrite)
    defer: settingFile.close()
    try:
      settingFile.write("")
    except:
      echo mlm.failedToCreateSettingFile
      return
    echo mlm.settingFileCreated
  echo mlm.initializationFinished


proc scanCommand(args: seq[string]) =
  if not settingFilePath.fileExists:
    echo mlm.noSettingFileDetected
    return
  echo mlm.usingXAsASettingFile(settingFilePath)
  echo mlm.loadingAndParsingSettingFile
  # let settingYaml = loadYaml(settingFilePath)
  # let setting = parseSettingsYaml(settingYaml)
  let settingJson = loadJson(settingFilePath)
  let setting = parseSettingJson(settingJson)

  let t1 = cpuTime()
  let scanResult = scan(setting, appDirPath, fn=proc()=discard)
  let timeTakenForScanMilliseconds = (cpuTime() - t1) * 1000

  echo mlm.scanFinishedSuccessfully
  # if not scanResult.succeeded:
  echo mlm.XImproperItemsOutOfYItemFound(
    scanResult.violationItems.len, scanResult.scannedItemsNumber
  )
  echo mlm.timeTakenForScanWasXMilliseconds(timeTakenForScanMilliseconds)
  # echo mlm.scanResult(scanResult)
  system.echo scanResult.format


when isMainModule:
  import cligen
  dispatchMulti(
    [initCommand, cmdName="init"],
    [scanCommand, cmdName="scan"],
  )
