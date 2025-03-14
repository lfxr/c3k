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
  byte = 1
  kibibyte = 1024
  mebibyte = 1024 ^ 2
  gibibyte = 1024 ^ 3


type Size* = tuple[
  comparisonOperator: ComparisonOperator,
  size: int,
  unit: DataUnit,
]


type Existence* = enum
  required = "required",
  disallowed = "disallowed",


type MetaRules* = tuple[
  existence: Option[Existence],
]


type ChildItemRules* = tuple[
  itemTypes:     Option[seq[ItemType]],
  itemFullname:  Option[string],
  itemFullnames: Option[seq[string]],
  itemName:      Option[string],
  itemNames:     Option[seq[string]],
  ext:           Option[string],
  exts:          Option[seq[string]],
  subExt:        Option[string],
  subExts:       Option[seq[string]],
  itemSize:      Option[Size],
  fileFullname:  Option[string],
  fileFullnames: Option[seq[string]],
  fileName:      Option[string],
  fileNames:     Option[seq[string]],
  fileSize:      Option[Size],
  dirName:       Option[string],
  dirNames:      Option[seq[string]],
  dirSize:       Option[Size],
]


type Regulation* = tuple[
  path: string,
  ignores: Option[seq[string]],
  rules: tuple[
    metaRules: MetaRules,
    childItemRules: ChildItemRules,
  ],
]


type Setting* = object
  ignores*: seq[string]
  regulations*: seq[Regulation]


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


type ViolationKind* {.pure.} = enum
  existence,
  itemType,
  itemFullname,
  itemName,
  ext,
  exts,
  subExt,
  subExts,
  itemSize,
  fileFullname,
  fileName,
  fileSize,
  dirName,
  dirSize,


type Violation* = tuple[
  kind: ViolationKind,
  expected, actual: string,
]


type ViolatingItem* = tuple[
  path: string,
  itemType: ItemType,
  violations: seq[Violation],
]


type ScanResult* = object
  scannedItemsNumber*: Natural
  violatingItemsNumber*: Natural
  violatingItems*: seq[ViolatingItem]
