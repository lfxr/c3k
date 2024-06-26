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
  itemFullname: string,
  itemName: string,
  itemExt: string,
]


type Reason {.pure.} = enum
  itemType,
  itemFullName,
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
        ].filterIt(it.result).mapIt(it.reason)
      echo reasons
      if reasons.len == 0:
        continue
      result.failedItems.add((
        itemPath: item.path,
        itemType: itemType,
        reasons: reasons
      ))
