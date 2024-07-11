import
  strformat

import
  types


const multiLangMessages* = (
  prefixes: (
    info: (
      emoji: "ℹ️",
      text: (
        ja_JP: "情報",
        en_GB: "Info",
      )
    )
  ),
  bodies: (
    usingXAsASettingFile: proc(x: string): MultiLangMessage = (
      emoji: "⚙",
      text: (
        ja_JP: &"'{x}'を設定ファイルとして使用します",
        en_GB: &"Using '{x}' as a setting file",
      )
    ),
  )
)
