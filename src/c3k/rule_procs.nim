import
  options,
  os,
  sequtils,
  strutils

import
  glob,
  regex

import
  utils/item,
  types


func isIgnore*(path: string, ignores: seq[string]): bool =
  type StringType = enum
    literal, glob, regex
  type MagicString = tuple[
    stringType: StringType,
    value: string,
  ]
  func type(s: string): StringType =
    if s.startsWith("r:"):
      StringType.regex
    elif s.startsWith("g:"):
      StringType.glob
    else:
      StringType.literal
  func deserializeMagicString(s: string): MagicString =
    (
      stringType: s.type,
      value:
        if s.type == StringType.literal: s
        else: s[2..^1]
    )
  # a.txt, *.ini, 
  ignores
    .map(deserializeMagicString)
    .filterIt(
      case it.stringType:
        of StringType.literal: it.value == path.lastPathPart
        of StringType.glob:    path.lastPathPart.matches(it.value.glob)
        of StringType.regex:   path.lastPathPart.match(re2 it.value)
    ).len > 0


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
        kind: ViolationKind.exts,
        expected: $rule.get,
        actual: item.ext
      )
    )


func subExt(item: ItemMetaData, regulation: Regulation): RuleProcResult =
  result.isViolated = false

  let rule = regulation.rules.childItems.subExt
  if rule.isNone:
    return
  if item.subExt != rule.get:
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.subExt,
        expected: rule.get,
        actual: item.subExt
      )
    )


func subExts(item: ItemMetaData, regulation: Regulation): RuleProcResult =
  result.isViolated = false

  let rule = regulation.rules.childItems.subExts
  if rule.isNone:
    return
  if item.subExt notin rule.get:
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.subExts,
        expected: $rule.get,
        actual: item.subExt
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
  (procedure: subExt, targetItemTypes: @[file]),
  (procedure: subExts, targetItemTypes: @[file]),
  # (function: ext, targetItemTypes: @[file]),
  # (function: itemSize, targetItemTypes: @[file, dir]),
]
