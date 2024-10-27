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


type Regulation* = tuple[
  path: string,
  ignores: Option[seq[string]],
  rules: tuple[
    currentDir: string, # 仮
    childItems: tuple[
      itemTypes: Option[seq[ItemType]],
      itemFullname: Option[string],
      itemFullnames: Option[seq[string]],
      itemName: Option[string],
      itemNames: Option[seq[string]],
      ext: Option[string],
      exts: Option[seq[string]],
      itemSize: Option[Size],
      fileFullname: Option[string],
      fileFullnames: Option[seq[string]],
      fileName: Option[string],
      fileNames: Option[seq[string]],
      fileSize: Option[Size],
      dirName: Option[string],
      dirNames: Option[seq[string]],
      dirSize: Option[Size],
    ],
  ],
]


type Setting* = object
  ignores*: seq[string]
  regulations*: seq[Regulation]


type RuleYaml* = object
  path*: string
  ignores* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  itemTypes* {.defaultVal: none(seq[ItemType]).}: Option[seq[ItemType]]
  itemFullname* {.defaultVal: none(string).}: Option[string]
  itemFullnames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  itemName* {.defaultVal: none(string).}: Option[string]
  itemNames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  ext* {.defaultVal: none(string).}: Option[string]
  exts* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  itemSize* {.defaultVal: none(string).}: Option[string]
  fileFullname* {.defaultVal: none(string).}: Option[string]
  fileFullnames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  fileName* {.defaultVal: none(string).}: Option[string]
  fileNames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  fileSize* {.defaultVal: none(string).}: Option[string]
  dirName* {.defaultVal: none(string).}: Option[string]
  dirNames* {.defaultVal: none(seq[string]).}: Option[seq[string]]
  dirSize* {.defaultVal: none(string).}: Option[string]


type SettingYaml* = object
  ignores*: seq[string]
  regulations*: seq[RuleYaml]


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


type Violation* = tuple[
  kind: ScanningFailureReason,
  expected, actual: string,
]


type ScanResult* = object
  scannedItemsNumber*: Natural
  violationItemsNumber*: Natural
  violationItems*: seq[tuple[
    path: string,
    itemType: ItemType,
    violations: seq[Violation],
  ]]
