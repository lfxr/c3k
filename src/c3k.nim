import
  m17n,
  messages,
  types,
  c3k/main,
  c3k/scan_result


proc scan() =
  let m17nEcho = m17nEcho(ja_JP)
  let settingsFilepath = "src/.c3k.yaml"
  m17nEcho multiLangMessages.usingXAsASettingFile(settingsFilepath)
  m17nEcho multiLangMessages.loadingAndParsingSettingFile
  let settingsYaml = loadYaml(settingsFilepath)
  echo settingsYaml
  let settings = parseSettingsYaml(settingsYaml)
  echo settings
  let scanResult = scan(settings, proc()=discard)
  echo scanResult
  m17nEcho multiLangMessages.scanFinishedSuccessfuly
  #m17nEcho multiLangMessages.scanResult(scanResult)
  echo scanResult.format


when isMainModule:
  scan()
