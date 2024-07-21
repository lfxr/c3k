import
  strutils

import
  terminaltables

import
  ../types,
  types


proc format*(scanResult: ScanResult): string = 
  let t2 = newUnicodeTable()
  t2.separateRows = false
  t2.setHeaders(
    @[
      newCell("パス", rightpad=10),
      newCell("タイプ", pad=2),
      newCell("理由", 5)
    ]
  )
  for failedItem in scanResult.failedItems:
    t2.addRow(@[failedItem.itemPath, $failedItem.itemType, $failedItem.reasons.join(", ")])
  printTable(t2)
