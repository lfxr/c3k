import
  sequtils,
  strutils

import
  terminaltables

import
  types


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
  for violationItem in scanResult.violationItems:
    t2.addRow(@[
      violationItem.path,
      $violationItem.itemType,
      violationItem.violations.mapIt($it.kind).join(", "),
    ])
  printTable(t2)
