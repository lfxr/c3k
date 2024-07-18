import
  strformat

import
  types


const multiLangPrefixes = (
  info: (
    emoji: "ℹ️",
    text: (
      ja_JP: "情報",
      en_GB: "INFO",
    )
  ),
  warning: (
    emoji: "⚠️",
    text: (
      ja_JP: "警告",
      en_GB: "WARN",
    ),
  ),
  error: (
    emoji: "❌",
    text: (
      ja_JP: "エラー",
      en_GB: "ERRR",
    ),
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
  noSettingFileDetected: (
    prefix: multiLangPrefixes.error,
    body: (
      emoji: "⚙",
      text: (
        ja_JP: "設定ファイルが検出されませんでした",
        en_GB: "No setting file detected",
      ),
    ),
  ),
  loadingAndParsingSettingFile: (
    prefix: multiLangPrefixes.info,
    body: (
      emoji: "🔄",
      text: (
        ja_JP: "設定ファイルを読み込んで解析しています",
        en_GB: "Loading and parsing the setting file",
      ),
    ),
  ),
  failedToParseSettingFile: (
    prefix: multiLangPrefixes.error,
    body: (
      emoji: "🔄",
      text: (
        ja_JP: "設定ファイルの解析に失敗しました",
        en_GB: "Failed to parse the setting file",
      ),
    ),
  ),
  scanningDirectoryX: proc(x: string): MultiLangMessage = (
    prefix: multiLangPrefixes.info,
    body: (
      emoji: "🔍",
      text: (
        ja_JP: &"ディレクトリ'{x}'をスキャンしています",
        en_GB: &"Scanning the directory '{x}'",
      ),
    ),
  ),
  improperItemFoundX: proc(x: string): MultiLangMessage = (
    prefix: multiLangPrefixes.warning,
    body: (
      emoji: "⚠️",
      text: (
        ja_JP: &"不適切なアイテム'{x}'が見つかりました",
        en_GB: &"Improper item '{x}' found",
      ),
    ),
  ),
  scanFinishedSuccessfuly: (
    prefix: multiLangPrefixes.info,
    body: (
      emoji: "✅",
      text: (
        ja_JP: "スキャンが正常に終了しました",
        en_GB: "Scan finished successfuly",
      ),
    ),
  ),
  XImproperItemsOutOfYItemFound: proc(x, y: int): MultiLangMessage = (
    prefix: multiLangPrefixes.warning,
    body: (
      emoji: "⚠️",
      text: (
        ja_JP: &"{x}個の不適切なアイテムが{y}個のアイテムの中で見つかりました",
        en_GB: &"{x} improper items out of {y} items found",
      ),
    ),
  ),
)
