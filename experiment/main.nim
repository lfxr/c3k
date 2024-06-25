import
  os,
  nre,
  sequtils


type ItemType = enum
  file,
  dir


type Rule* = tuple[
  path: string,
  itemTypes: seq[ItemType],
  itemName: string,
  itemExt: string,
]


type Reason {.pure.} = enum
  itemType,
  itemName,
  itemExt,


type ScanResult = tuple[
  failedItems: seq[
    tuple[
      itemPath: string,
      itemType: ItemType,
      reasons: seq[Reason]
    ]
  ]
]


func match(target, pattern: string): bool =
  target.match(re(pattern)).isSome


func isItemTypes(itemType: ItemType, itemTypes: seq[ItemType]): bool =
  itemType in itemTypes


func isItemName(name, pattern: string): bool =
  not name.match(pattern)


func isItemExt(ext, pattern: string): bool =
  not ext.match(pattern)


proc scan*(rules: seq[Rule]): ScanResult =
  for rule in rules:
    for item in walkDir(rule.path.expandTilde):
      let
        itemType =
          if item.path.fileExists: file
          else: dir
        itemName = item.path.splitFile.name
        itemExt = item.path.splitFile.ext
      let reasons: seq[Reason] = @[
          (reason: Reason.itemType, result: isItemTypes(itemType, rule.itemTypes)),
          (reason: Reason.itemName, result: isItemName(itemName, rule.itemName)),
          (reason: Reason.itemExt, result: isItemExt(itemExt, rule.itemExt)),
        ].filterIt(it.result).mapIt(it.reason)
      echo reasons
      if reasons.len == 0:
        continue
      result.failedItems.add((
        itemPath: item.path,
        itemType: itemType,
        reasons: reasons
      ))
