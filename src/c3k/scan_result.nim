import
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
      newCell("理由", rightpad=5)
    ]
  )
  for failedItem in scanResult.failedItems:
    t2.addRow(@[failedItem.itemPath, $failedItem.itemType, $failedItem.reasons.join(", ")])
  printTable(t2)
