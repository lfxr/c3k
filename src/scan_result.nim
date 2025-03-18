import
  sequtils,
  strutils

import
  terminaltables

import
  c3k/types


proc format*(scanResult: ScanResult): string =
  let t2 = newUnicodeTable()
  t2.separateRows = false
  t2.setHeaders(
    @[
      newCell("パス", rightpad=25),
      newCell("タイプ", rightpad=5),
      newCell("理由", rightpad=5),
    ]
  )
  for violatingItem in scanResult.violatingItems:
    t2.addRow(@[
      violatingItem.path,
      $violatingItem.itemKind,
      violatingItem.violations.mapIt($it.kind).join(", "),
    ])
  printTable(t2)
