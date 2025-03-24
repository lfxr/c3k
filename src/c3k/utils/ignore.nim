import
  strutils,
  sequtils

import
  ../types


type IgnorePatternType = enum
  absolute,
  relative,
  anywhere,

type IgnorePattern = object
  patternType: IgnorePatternType
  raw, normalized: string
  targetItemKinds: seq[ItemKind]
  isNegation: bool
  appliedFrom: string

type IgnorePredicate = proc (
    itemPath: string, itemKind: ItemKind, workingDir: string
): bool {.noSideEffect.}


func normalize(rawPattern: string): string =
  if rawPattern.startsWith("!"):
    rawPattern[1..^1]
  else:
    rawPattern


func targetItemKinds(rawPattern: string): seq[ItemKind] =
  if rawPattern.endsWith("/"):
    @[dir]
  else:
    @[file, dir]


func newIgnorePattern(rawPattern: string, appliedFrom: string): ref IgnorePattern =
  result = new IgnorePattern
  result.raw = rawPattern
  # TODO: Implement pattern normalization
  result.normalized = rawPattern.normalize
  result.targetItemKinds = rawPattern.targetItemKinds
  result.isNegation = rawPattern.startsWith("!")
  result.appliedFrom = appliedFrom


# func matches(pattern: ref IgnorePattern, item: ref Item): bool =
#   return case pattern.patternType
#   of IgnorePatternType.absolute:
#     item.path == pattern.normalized
#   of IgnorePatternType.relative:
#     item.path.toLower.contains(pattern.normalized.toLower())
#   of IgnorePatternType.anyWhere:
#     item.path.toLower.contains(pattern.normalized.toLower())


func ignorePredicate(patterns: seq[ref IgnorePattern]): IgnorePredicate =
  func (itemPath: string, itemKind: ItemKind, workingDir: string): bool =
    result = false
    for pattern in patterns:
      if itemKind notin pattern.targetItemKinds:
        continue
      if pattern.normalized == itemPath:
        result = not pattern.isNegation


when isMainModule:
  let
    patterns: seq[ref IgnorePattern] = @[
      newIgnorePattern("/desktop.ini", ""),
      newIgnorePattern("!/desktop.ini", ""),
    ]
    predicate: IgnorePredicate = ignorePredicate(patterns)
  doAssert not predicate("/desktop.ini", file, "")
