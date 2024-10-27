import
  nre,
  options,
  os,
  sequtils

import
  types


func sandwichWithAnchors(pattern: string): string =
  "^" & pattern & "$"


func find(target, pattern: string): bool =
  target.find(pattern.sandwichWithAnchors.re).isSome


func isIgnore*(path: string, ignores: seq[string]): bool =
  ignores.filterIt(path.find(it)).len > 0


func itemType*(item: Item): ItemType =
  if item.kind == pcFile: file
  else: dir


type ItemMetaData = tuple[
  path: string,
  itemType: ItemType, 
]


func metaData*(item: Item): ItemMetaData =
  (path: item.path, itemType: itemType(item))


type RuleProcResult = tuple[
  succeeded: bool,
  violation: Violation,
]


proc itemType(item: ItemMetaData, regulation: Regulation): RuleProcResult =
  # 1は名前重複回避のため仮
  let rule = regulation.rules.childItems.itemTypes
  if rule.isNone:
    result.succeeded = true
    return
  if item.itemType notin rule.get:
    return (
      succeeded: false,
      violation: (
        kind: ViolationKind.itemType,
        expected: $rule.get,
        actual: $item.itemType
      )
    )


type RuleProc = tuple[
  procedure: proc(item: ItemMetaData, regulation: Regulation): RuleProcResult,
  targetItemTypes: seq[ItemType]
]


const RuleProcs*: seq[RuleProc] = @[
  (procedure: itemType, targetItemTypes: @[file, dir]),
  # (function: ext, targetItemTypes: @[file]),
  # (function: itemSize, targetItemTypes: @[file, dir]),
]
