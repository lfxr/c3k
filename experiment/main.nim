import
  os,
  nre,
  sequtils,
  math


type ItemType = enum
  file,
  dir


type ComparisonOperator* = enum
  lessThan,
  lessThanOrEqual,
  greaterThan,
  greaterThanOrEqual,
  equal,


type DataUnit* = enum
  byte = 1,
  kibibyte = 1024,
  mebibyte = 1024 ^ 2,
  gibibyte = 1024 ^ 3,


type Size* = tuple[
  comparisonOperator: ComparisonOperator,
  size: int,
  unit: DataUnit
]


type Rule* = tuple[
  path: string,
  itemTypes: seq[ItemType],
  itemFullname: string,
  itemName: string,
  itemExt: string,
  itemSize: Size
]


type Reason {.pure.} = enum
  itemType,
  itemFullName,
  itemName,
  itemExt,
  itemSize,


type ScanResult = tuple[
  failedItems: seq[
    tuple[
      itemPath: string,
      itemType: ItemType,
      reasons: seq[Reason]
    ]
  ]
]


func find(target, pattern: string): bool =
  target.find(re(pattern)).isSome


func isIgnore(path: string, ignores: seq[string]): bool =
  ignores.filterIt(path.find(it)).len > 0


func isItemTypes(itemType: ItemType, itemTypes: seq[ItemType]): bool =
  not (itemType in itemTypes)


func isItemFullName(name, pattern: string): bool =
  not name.find(pattern)


func isItemName(name, pattern: string): bool =
  not name.find(pattern)


func isItemExt(ext, pattern: string): bool =
  not ext.find(pattern)


func isItemSize(actualSizeBytes: int, expectedSize: Size): bool =
  let comparisonFunc = func (a, b: int): bool =
    case expectedSize.comparisonOperator:
      of ComparisonOperator.lessThan:
        a < b
      of ComparisonOperator.lessThanOrEqual:
        a <= b
      of ComparisonOperator.greaterThan:
        a > b
      of ComparisonOperator.greaterThanOrEqual:
        a >= b
      of ComparisonOperator.equal:
        a == b
  return not comparisonFunc(
    actualSizeBytes, expectedSize.size * expectedSize.unit.int
  )


proc scan*(rules: seq[Rule], ignores: seq[string]): ScanResult =
  for rule in rules:
    for item in walkDir(rule.path.expandTilde):
      if isIgnore(item.path, ignores):
        continue
      let
        itemType =
          if item.kind == pcFile: file
          else: dir
        itemName =
          if itemType == file: item.path.splitFile.name
          else: item.path.lastPathPart
        itemExt = item.path.splitFile.ext
      let reasons: seq[Reason] = @[
          (reason: Reason.itemType, result: isItemTypes(itemType, rule.itemTypes)),
          (
            reason: Reason.itemFullName,
            result: isItemFullName(item.path.extractFilename, rule.itemFullname)
          ),
          (reason: Reason.itemName, result: isItemName(itemName, rule.itemName)),
          (reason: Reason.itemExt, result: isItemExt(itemExt, rule.itemExt)),
          (
            reason: Reason.itemSize,
            result: isItemSize(item.path.getFileSize, rule.itemSize)
          ),
        ].filterIt(it.result).mapIt(it.reason)
      echo reasons
      if reasons.len == 0:
        continue
      result.failedItems.add((
        itemPath: item.path,
        itemType: itemType,
        reasons: reasons
      ))
