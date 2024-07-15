import
  strformat

import
  types


func m17n(language: Language): proc(message: MultiLangMessage): Message =
  func(message: MultiLangMessage): Message = (
    prefix: (
      emoji: message.prefix.emoji,
      text: case language:
        of ja_JP: message.prefix.text.ja_JP
        of en_GB: message.prefix.text.en_GB,
    ),
    body: (
      emoji: message.body.emoji,
      text: case language:
        of ja_JP: message.body.text.ja_JP
        of en_GB: message.body.text.en_GB
    ),
  )


func serialize(message: Message): string =
  let
    prefix = message.prefix
    body = message.body
  return &"""[{prefix.emoji} {prefix.text}] {body.emoji} {body.text}"""


func m17nEcho*(lang: Language): proc(message: MultiLangMessage) =
  proc(message: MultiLangMessage) =
    echo m17n(lang)(message).serialize
