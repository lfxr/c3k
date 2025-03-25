import
  os,
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


func ignorePatternType(normalized: string): IgnorePatternType =
  if normalized.startsWith("/"):
    absolute
  elif normalized.startsWith("./"):
    relative
  else:
    anywhere


func normalize(rawPattern: string): string =
  result = rawPattern
  if rawPattern.startsWith("!"):
    result = result[1..^1]
  if rawPattern.endsWith("/"):
    result = result[0..^2]


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
  result.patternType = result.normalized.ignorePatternType
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
      case pattern.patternType:
      of IgnorePatternType.absolute:
        if pattern.normalized == itemPath:
          result = not pattern.isNegation
      of IgnorePatternType.relative:
        let patternAbsolutePath = pattern.appliedFrom / pattern.normalized
        if patternAbsolutePath == itemPath:
          result = not pattern.isNegation
      of IgnorePatternType.anywhere:
        if itemPath.endsWith(pattern.normalized):
          result = not pattern.isNegation


when isMainModule:
  let
    patterns1: seq[ref IgnorePattern] = @[
      newIgnorePattern("/desktop.ini", ""),
      newIgnorePattern("!/desktop.ini", ""),
    ]
    predicate1: IgnorePredicate = ignorePredicate(patterns1)
  doAssert not predicate1("/desktop.ini", file, "")

  let
    patterns2: seq[ref IgnorePattern] = @[
      newIgnorePattern("desktop.ini", ""),
    ]
    predicate2: IgnorePredicate = ignorePredicate(patterns2)
  doAssert predicate2("/desktop.ini", file, "")
  doAssert predicate2("/desktop.ini", dir, "")
  doAssert predicate2("/path/desktop.ini", file, "")
  doAssert predicate2("/path/to/desktop.ini", file, "")
  doAssert not predicate2("/path/to/desktop.ini/path", file, "")

  let
    patterns3: seq[ref IgnorePattern] = @[
      newIgnorePattern(".git/", ""),
    ]
    predicate3: IgnorePredicate = ignorePredicate(patterns3)
  doAssert predicate3(".git", dir, "")
  doAssert not predicate3("/.git/foo", dir, "")
  doAssert predicate3("/foo/.git", dir, "")
