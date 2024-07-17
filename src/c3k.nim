import
  m17n,
  messages,
  types,
  c3k/main


proc scan() =
  let m17nEcho = m17nEcho(ja_JP)
  let settingsFilepath = "src/.c3k.yaml"
  m17nEcho multiLangMessages.usingXAsASettingFile(settingsFilepath)
  let settingsYaml = loadYaml(settingsFilepath)
  echo settingsYaml
  let settings = parseSettingsYaml(settingsYaml)
  echo settings
  let scanResult = scan(settings, proc()=discard)
  echo scanResult


when isMainModule:
  scan()
