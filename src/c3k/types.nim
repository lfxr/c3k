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
  itemExt: Option[string],
  itemSize: Option[Size],
]


type Setting* = object
  ignores*: seq[string]
  rules*: seq[Rule]


type RuleYaml* = object
  path*: string
  itemTypes* {.defaultVal: none(seq[ItemType]).}: Option[seq[ItemType]]
  itemFullname* {.defaultVal: none(string).}: Option[string]
  itemName* {.defaultVal: none(string).}: Option[string]
  itemExt* {.defaultVal: none(string).}: Option[string]
  itemSize* {.defaultVal: none(string).}: Option[string]


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
