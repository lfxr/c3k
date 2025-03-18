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


type RuleProcResult* = tuple[
  isViolated: bool,
  violation: Option[Violation],
]


proc existence(itemMetaData: ItemMetaData, metaRules: MetaRules): RuleProcResult =
  debugEcho itemMetaData
  debugEcho metaRules
  result.isViolated = false

  let rule = metaRules.existence
  if rule.isNone:
    return
  if rule.get == required and not dirExists(itemMetaData.path):
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.existence,
        expected: $rule.get,
        actual: "not exist",
      )
    )
  if rule.get == disallowed and dirExists(itemMetaData.path):
    return (
      isViolated: true,
      violation: option (
        kind: ViolationKind.existence,
        expected: $rule.get,
        actual: "exist",
      )
    )


func itemTypes(item: ItemMetaData, childItemRules: ChildItemRules): RuleProcResult =
  result.isViolated = false

  let rule = childItemRules.itemTypes
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


func ext(item: ItemMetaData, childItemRules: ChildItemRules): RuleProcResult =
  result.isViolated = false

  let rule = childItemRules.ext
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


func exts(item: ItemMetaData, childItemRules: ChildItemRules): RuleProcResult =
  result.isViolated = false

  let rule = childItemRules.exts
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


func subExt(item: ItemMetaData, childItemRules: ChildItemRules): RuleProcResult =
  result.isViolated = false

  let rule = childItemRules.subExt
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


func subExts(item: ItemMetaData, childItemRules: ChildItemRules): RuleProcResult =
  result.isViolated = false

  let rule = childItemRules.subExts
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


type MetaRuleProc* = tuple[
  procedure:
    proc(item: ItemMetaData, metaRules: MetaRules): RuleProcResult {.nimcall.},
]


type ChildItemRuleProc* = tuple[
  procedure:
    proc(item: ItemMetaData, childItemRules: ChildItemRules): RuleProcResult {.nimcall.},
  targetItemTypes: seq[ItemType]
]


const MetaRuleProcs*: seq[MetaRuleProc] = @[
  (procedure: existence),
]


const ChildItemRuleProcs*: seq[ChildItemRuleProc] = @[
  (procedure: itemTypes, targetItemTypes: @[file, dir]),
  (procedure: ext, targetItemTypes: @[file]),
  (procedure: exts, targetItemTypes: @[file]),
  (procedure: subExt, targetItemTypes: @[file]),
  (procedure: subExts, targetItemTypes: @[file]),
  # (function: ext, targetItemTypes: @[file]),
  # (function: itemSize, targetItemTypes: @[file, dir]),
]


type ItemMetadataRuleVerifier = tuple[
  verifier: ItemMetadataVerifier,
  targetItemKind: seq[ItemKind],
]


const ItemMetadataRuleVerifiers*: seq[ItemMetadataRuleVerifier] = @[
  (verifier: kind, targetItemKind: @[file, dir]),
]
