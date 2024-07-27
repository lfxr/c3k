import
  m17n,
  messages,
  types,
  c3k/main,
  c3k/scan_result


proc scan() =
  let m17nEcho = m17nEcho(ja_JP)
  let settingFilePath = "src/.c3k.yaml"
  m17nEcho multiLangMessages.usingXAsASettingFile(settingFilePath)
  m17nEcho multiLangMessages.loadingAndParsingSettingFile
  let settingYaml = loadYaml(settingFilePath)
  echo settingYaml
  let setting = parseSettingsYaml(settingYaml)
  let scanResult = scan(setting, proc()=discard)
  echo scanResult
  m17nEcho multiLangMessages.scanFinishedSuccessfuly
  #m17nEcho multiLangMessages.scanResult(scanResult)
  echo scanResult.format


when isMainModule:
  scan()
