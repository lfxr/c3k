import
  types


func m17n*(language: Language): proc(message: MultiLangMessage): Message =
  func(message: MultiLangMessage): Message = (
    emoji: message.emoji,
    text: case language:
      of ja_JP: message.text.ja_JP
      of en_GB: message.text.en_GB
  )
