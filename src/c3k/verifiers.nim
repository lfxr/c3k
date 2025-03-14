import
  options,
  sequtils

import
  rule_procs,
  types,
  utils/item


func verify(
    metaRules: MetaRules,
    itemMetaDataSeq: seq[ItemMetaData]
): seq[ViolatingItem] =
  for itemMetaData in itemMetaDataSeq:
    let violations = MetaRuleProcs
        .map(
          proc (metaRuleProc: MetaRuleProc): RuleProcResult =
            metaRuleProc.procedure(itemMetaData, metaRules)
        )
        .filterIt(it.isViolated)
        .mapIt(it.violation.get)

    if violations.len == 0:
      continue

    result.add((
      path: itemMetaData.path,
      itemType: itemMetaData.itemType,
      violations: violations,
    ))


func verify(
    childItemRules: ChildItemRules,
    itemMetaDataSeq: seq[ItemMetaData]
): seq[ViolatingItem] =
  for itemMetaData in itemMetaDataSeq:
    let violations = ChildItemRuleProcs
        .map(
          proc (childItemRuleProc: ChildItemRuleProc): RuleProcResult =
            childItemRuleProc.procedure(itemMetaData, childItemRules)
        )
        .filterIt(it.isViolated)
        .mapIt(it.violation.get)

    if violations.len == 0:
      continue

    result.add((
      path: itemMetaData.path,
      itemType: itemMetaData.itemType,
      violations: violations,
    ))


func verify*(regulation: Regulation, globalIgnores: seq[string]): seq[ViolatingItem] =
  #let items = regulation.path.getItems()
  let items: seq[ItemMetaData] = @[
    (
      path: "/mnt/c/users/user/Downloads",
      itemType: dir,
      ext: "",
      subExt: "",
    ),
    (
      path: "/mnt/c/users/user/Downloads/abc.txt",
      itemType: file,
      ext: "txt",
      subExt: "",
    ),
  ]
  result.add(regulation.rules.metaRules.verify(items))
  result.add(regulation.rules.childItemRules.verify(items))
