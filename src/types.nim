type Language* = enum
  ja_JP,
  en_GB


type MultiLangMessage* = tuple[
  emoji: string,
  text: tuple[
    ja_JP: string,
    en_GB: string,
  ],
]


type Message* = tuple[
  emoji: string,
  text: string,
]
