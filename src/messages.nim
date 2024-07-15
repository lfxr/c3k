import
  strformat

import
  types


const multiLangPrefixes: MultiLangPrefixes = (
  info: (
    emoji: "ℹ️",
    text: (
      ja_JP: "情報",
      en_GB: "Info",
    )
  ),
)


const multiLangMessages* = (
  usingXAsASettingFile: proc(x: string): MultiLangMessage = (
    prefix: multiLangPrefixes.info,
    body: (
      emoji: "⚙",
      text: (
        ja_JP: &"'{x}'を設定ファイルとして使用します",
        en_GB: &"Using '{x}' as a setting file",
      ),
    ),
  ),
)
