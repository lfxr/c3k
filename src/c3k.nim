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
  let settingsFilepath = "src/.c3k.yaml"
  echo echoMessage(
    m17n(multiLangMessages.prefixes.info),
    m17n(multiLangMessages.bodies.usingXAsASettingFile(settingsFilepath))
  )
  let settingsYaml = loadYaml(settingsFilepath)
  echo settingsYaml
  let settings = parseSettingsYaml(settingsYaml)
  echo settings


when isMainModule:
  scan()
