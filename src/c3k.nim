import
  strformat

import
  m17n,
  messages,
  types,
  c3k/main


func echoMessage(prefix, body: Message): string =
  &"""[{prefix.emoji} {prefix.text}] {body.emoji} {body.text}"""


proc scan() =
  let m17n = m17n(ja_JP)
  let settingsFilepath = ".c3k.yaml"
  let settingsYaml = loadYaml(settingsFilepath)
  let settings = parseSettingsYaml(settingsYaml)
  let prefix = multiLangMessages.prefixes.info
  let body = multiLangMessages.bodies.usingXAsASettingFile(settingsFilepath)
  echo echoMessage(
    prefix.m17n,
    body.m17n
  )


when isMainModule:
  scan()
