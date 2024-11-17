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
  ext: string,
]


func metaData*(item: Item): ItemMetaData =
  (
    path: item.path,
    itemType: itemType(item),
    ext: item.path.splitFile.ext,
  )


type RuleProcResult = tuple[
  isViolated: bool,
  violation: Option[Violation],
]


func itemType(item: ItemMetaData, regulation: Regulation): RuleProcResult =
  result.isViolated = false

  let rule = regulation.rules.childItems.itemTypes
  if rule.isNone:
    return
  if item.itemType notin rule.get:
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.itemType,
        expected: $rule.get,
        actual: $item.itemType
      )
    )


func ext(item: ItemMetaData, regulation: Regulation): RuleProcResult =
  result.isViolated = false

  let rule = regulation.rules.childItems.ext
  if rule.isNone:
    return
  if item.ext != rule.get:
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.ext,
        expected: rule.get,
        actual: item.ext
      )
    )


func exts(item: ItemMetaData, regulation: Regulation): RuleProcResult =
  result.isViolated = false

  let rule = regulation.rules.childItems.exts
  if rule.isNone:
    return
  if item.ext notin rule.get:
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.ext,
        expected: $rule.get,
        actual: item.ext
      )
    )


type RuleProc = tuple[
  procedure:
    proc(item: ItemMetaData, regulation: Regulation): RuleProcResult {.nimcall.},
  targetItemTypes: seq[ItemType]
]


let RuleProcs*: seq[RuleProc] = @[
  (procedure: itemType, targetItemTypes: @[file, dir]),
  (procedure: ext, targetItemTypes: @[file]),
  (procedure: exts, targetItemTypes: @[file]),
  # (function: ext, targetItemTypes: @[file]),
  # (function: itemSize, targetItemTypes: @[file, dir]),
]
