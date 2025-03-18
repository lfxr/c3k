import
  options,
  sequtils

import
  rule,
  types


func verify(itemMetadataRules: ItemMetadataRules, items: seq[ItemMetadata]): seq[ViolatingItem] =
  for itemMetadata in items:
    var ruleVerifierResults: seq[RuleVerifierResult] = @[]
    block:
      ruleVerifierResults.add(itemMetadata.kinds(itemMetadataRules.kinds))
      ruleVerifierResults.add(itemMetadata.itemFullname(itemMetadataRules.itemFullname))
    let violations = ruleVerifierResults
        .filterIt(it.isViolated)
        .mapIt(it.violation.get)
        .mapIt((
          kind: it.kind,
          expected: it.expected,
          actual: it.actual,
        ))
    if violations.len != 0:
      result.add((
        path: itemMetadata.name, #path
        itemKind: itemMetadata.kind,
        violations: violations,
      ))



# func verify(itemDataRules: ItemDataRules, items: seq[Item]) =
#   # itemDataRuleVerifiers
#   #   .filterIt(it.targetItemTypes.contains(item.kind))
#   discard


func verify*(rules: Rules, items: seq[Item]): seq[ViolatingItem] =
  result.add(rules.itemMetadata.verify(items.mapIt(it.metadata)))
