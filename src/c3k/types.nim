import
  math,
  options,
  os

import
  yaml


type ItemType* = enum
  file,
  dir,


type ComparisonOperator* = enum
  lessThan           = "<",
  lessThanOrEqual    = "<=",
  greaterThan        = ">",
  greaterThanOrEqual = ">=",
  equal              = "==",


type DataUnit* = enum
  byte = 1,
  kibibyte = 1024,
  mebibyte = 1024 ^ 2,
  gibibyte = 1024 ^ 3,


type Size* = tuple[
  comparisonOperator: ComparisonOperator,
  size: int,
  unit: DataUnit,
]


type Rule* = tuple[
  path: string,
  itemTypes: Option[seq[ItemType]],
  itemFullname: Option[string],
  itemName: Option[string],
  ext: Option[string],
  itemSize: Option[Size],
  fileFullname: Option[string],
  fileName: Option[string],
  fileSize: Option[Size],
  dirName: Option[string],
  dirSize: Option[Size],
]


type Setting* = object
  ignores*: seq[string]
  rules*: seq[Rule]


type RuleYaml* = object
  path*: string
  itemTypes* {.defaultVal: none(seq[ItemType]).}: Option[seq[ItemType]]
  itemFullname* {.defaultVal: none(string).}: Option[string]
  itemName* {.defaultVal: none(string).}: Option[string]
  ext* {.defaultVal: none(string).}: Option[string]
  itemSize* {.defaultVal: none(string).}: Option[string]
  fileFullname* {.defaultVal: none(string).}: Option[string]
  fileName* {.defaultVal: none(string).}: Option[string]
  fileSize* {.defaultVal: none(string).}: Option[string]
  dirName* {.defaultVal: none(string).}: Option[string]
  dirSize* {.defaultVal: none(string).}: Option[string]


type SettingYaml* = object
  ignores*: seq[string]
  rules*: seq[RuleYaml]


type Item* = tuple[
  kind: PathComponent,
  path: string,
]


type ErrorKind* = enum
  invalidYaml,
  ioError,
  osError,


type Error* = object of CatchableError
  case kind*: ErrorKind
    of invalidYaml:
      path*: string
    of ioError:
      ioErrorObject*: ref IOError
    of osError:
      osErrorObject*: ref OSError


type ScanningFailureReason* {.pure.} = enum
  itemType,
  itemFullname,
  itemName,
  ext,
  itemSize,
  fileFullname,
  fileName,
  fileSize,
  dirName,
  dirSize,


type ScanResult* = tuple[
  succeeded: bool,
  totalItems: Natural,
  failedItems: seq[tuple[
    itemPath: string,
    itemType: ItemType,
    reasons: seq[ScanningFailureReason],
  ]],
]
