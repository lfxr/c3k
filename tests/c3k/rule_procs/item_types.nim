import
  options,
  unittest

import
  ../../../src/c3k/rule_procs {.all.},
  ../../../src/c3k/utils/item,
  ../../../src/c3k/types


func itemMetaData(itemType: ItemType): ItemMetaData =
  (path: "", itemType: itemType, ext: "", subExt: "",)


func regulation(itemTypes: Option[seq[ItemType]] = none(seq[ItemType])): Regulation =
  (
    path: "",
    ignores: none(seq[string]),
    rules: (
      currentDir: "",
      childItems: (
        itemTypes: itemTypes,
        itemFullname: none string,
        itemFullnames: none seq[string],
        itemName: none string,
        itemNames: none seq[string],
        ext: none string,
        exts: none seq[string],
        subExt: none string,
        subExts: none seq[string],
        itemSize: none Size,
        fileFullname: none string,
        fileFullnames: none seq[string],
        fileName: none string,
        fileNames: none seq[string],
        fileSize: none Size,
        dirName: none string,
        dirNames: none seq[string],
        dirSize: none Size,
      ),
    ),
  )


block:
  check itemTypes(itemMetaData(file), regulation(some @[file, dir])) == (
    isViolated: false,
    violation: none Violation,
  )


block:
  check itemTypes(itemMetaData(dir), regulation(some @[file, dir])) == (
    isViolated: false,
    violation: none Violation,
  )


block:
  check itemTypes(itemMetaData(file), regulation(some @[file])) == (
    isViolated: false,
    violation: none Violation,
  )


block:
  check itemTypes(itemMetaData(dir), regulation(some @[dir])) == (
    isViolated: false,
    violation: none Violation,
  )


block:
  check itemTypes(itemMetaData(file), regulation(some[seq[ItemType]] @[])) == (
    isViolated: true,
    violation: some((kind: ViolationKind.itemType, expected: "@[]", actual: "file"))
  )


block:
  check itemTypes(itemMetaData(dir), regulation(some[seq[ItemType]] @[])) == (
    isViolated: true,
    violation: some((kind: ViolationKind.itemType, expected: "@[]", actual: "dir"))
  )


block:
  check itemTypes(itemMetaData(file), regulation(none seq[ItemType])) == (
    isViolated: false,
    violation: none Violation,
  )
