import
  options,
  sequtils

import
  utils/item,
  rule_procs,
  types


proc scan*(regulation: Regulation): seq[Violation] =
  metaRuleProcs
    .mapIt(it.procedure(regulation))
    .filterIt(it.isViolated)
    .mapIt(it.violation.get)


proc scan*(item: Item, regulation: Regulation): seq[Violation] =
  # ruleFuncには適切なitemtypeが保証されている
  # そもそも用語の命名定義から始めた方が良い
  # ruleProcsを適用
  childItemRuleProcs
    .filterIt(item.metaData.itemType in it.targetItemTypes)
    .mapIt(it.procedure(item.metaData, regulation.rules.childItemRules))
    .filterIt(it.isViolated)
    .mapIt(it.violation.get)
