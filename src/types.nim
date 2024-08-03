type Language* = enum
  ja_JP,
  en_GB


type Prefix* = tuple[
  emoji: string,
  text: string,
]


type Message* = tuple[
  prefix: Prefix,
  body: tuple[
    emoji: string,
    text: string,
  ],
]


type MultiLang* = tuple[
  ja_JP, en_GB: string,
]


type MultiLangPrefix* = tuple[
  emoji: string,
  text: MultiLang,
]


type MultiLangPrefixes* = tuple[
  info: MultiLangPrefix,
]

type MultiLangMessage* = tuple[
  prefix: MultiLangPrefix,
  body: tuple[
    emoji: string,
    text: MultiLang,
  ],
]
