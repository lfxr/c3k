import
  nre,
  options,
  os,
  sequtils,
  strutils

import
  yaml

from glob import walkGlob

import
  utils/[
    item,
    path
  ],
  parse_setting,
  rule_procs,
  scan,
  types

export
  parse_setting


func containsGlob(path: string): bool = "*" in path


proc scan*(
    setting: Setting,
    workingDirPath: string,
    unexpandTilde: bool = true,
    fn: proc()
): ScanResult =
  setCurrentDir(workingDirPath)

  for regulation in setting.regulations:
    let matchedDirPaths =
      if regulation.path.containsGlob:
        # Globで取りこぼすディレクトリパスが存在するのか？
        let temp = walkGlob(regulation.path).toSeq.mapIt(it.splitFile.dir).deduplicate
        if temp.len == 0:
          walkPattern(regulation.path).toSeq
        else:
          temp
      else:
        walkPattern(regulation.path).toSeq

    for matchedDirPath in matchedDirPaths:
      for item in walkDir(matchedDirPath):
        result.scannedItemsNumber += 1
        # TODO: ignoreの仕様を再考
        if isIgnore(item.path.relativePath(matchedDirPath), setting.ignores):
          continue

        if isIgnore(
          item.path.relativePath(matchedDirPath),
          if regulation.ignores.isSome: regulation.ignores.get
          else: @[],
        ):
          continue

        let violations = item.scan(regulation)
        if violations.len == 0:
          continue

        result.violationItems.add((
          path:
            if unexpandTilde: item.path.unexpandTilde
            else: item.path,
          itemType: item.itemType,
          violations: violations,
        ))
