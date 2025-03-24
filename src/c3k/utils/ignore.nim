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
  isNegation: bool
  appliedFrom: string

type IgnorePredicate = proc (path, workingDir: string): bool {.noSideEffect.}


func normalize(rawPattern: string): string =
  if rawPattern.startsWith("!"):
    rawPattern[1..^1]
  else:
    rawPattern


func newIgnorePattern(rawPattern: string, appliedFrom: string): ref IgnorePattern =
  result = new IgnorePattern
  result.raw = rawPattern
  # TODO: Implement pattern normalization
  result.normalized = rawPattern.normalize
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
  func (path, workingDir: string): bool =
    result = false
    for pattern in patterns:
      if pattern.normalized == path:
        result = not pattern.isNegation


# func combine*(predicates: seq[IgnorePredicate]): IgnorePredicate =
#   func (path, workingDir: string): bool =
#     for predicate in predicates:
#       if not predicate(path, workingDir):
#         return false
#     return true


when isMainModule:
  let
    patterns: seq[ref IgnorePattern] = @[
      newIgnorePattern("/desktop.ini", ""),
      newIgnorePattern("!/desktop.ini", ""),
    ]
    predicate: IgnorePredicate = ignorePredicate(patterns)
  doAssert not predicate("/desktop.ini", "")
