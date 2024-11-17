import
  options,
  sequtils

import
  rule_procs,
  types


proc scan*(item: Item, regulation: Regulation): seq[Violation] =
  # ruleFuncには適切なitemtypeが保証されている
  # そもそも用語の命名定義から始めた方が良い
  # ruleProcsを適用
  RuleProcs
    .filterIt(item.metaData.itemType in it.targetItemTypes)
    .mapIt(it.procedure(item.metaData, regulation))
    .filterIt(it.isViolated)
    .mapIt(it.violation.get)
