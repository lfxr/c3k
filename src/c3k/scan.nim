import
  sequtils

import
  rule_procs,
  types


proc scan*(item: Item, regulation: Regulation): seq[Violation] =
  # ruleFuncには適切なitemtypeが保証されている
  # そもそも用語の命名定義から始めた方が良い
  echo regulation
  # ruleProcsを適用
  return RuleProcs.mapIt(it.procedure(item.metaData, regulation).violation)
