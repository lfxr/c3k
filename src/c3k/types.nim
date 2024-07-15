import
  math,
  options


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
  itemTypes: seq[ItemType],
  itemFullname: string,
  itemName: string,
  itemExt: string,
  itemSize: Size,
]


type Settings* = object
  ignores*: seq[string]
  rules*: seq[Rule]


type RuleYaml* = tuple[
  path: string,
  itemTypes: seq[ItemType],
  itemFullname: string,
  itemName: string,
  itemExt: string,
  itemSize: string,
]


type SettingsYaml* = object
  ignores*: seq[string]
  rules*: seq[RuleYaml]
