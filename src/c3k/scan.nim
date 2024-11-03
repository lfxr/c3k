import
  sequtils

import
  rule_procs,
  types


proc scan*(item: Item, regulation: Regulation): seq[Violation] =
  # ruleFuncには適切なitemtypeが保証されている
  # そもそも用語の命名定義から始めた方が良い
  # ruleProcsを適用
  RuleProcs
    .mapIt(it.procedure(item.metaData, regulation))
    .filterIt(it.isViolated)
    .mapIt(it.violation)
  # return RuleProcs.mapIt(it.procedure(item.metaData, regulation).violation)
