import
  options

import
  types


type RuleVerifierResult* = tuple[
  isViolated: bool,
  violation: Option[Violation],
]


func existence*(
    itemMetadata: ItemMetadata,
    rule: ItemMetadataRules.existence
): RuleVerifierResult =
  if rule.isNone:
    return
  if itemMetadata.exists and rule.get == disallowed or
    (not itemMetadata.exists) and rule.get == required:
    result.isViolated = true
    result.violation = option (
      kind: ViolationKind.existence,
      expected: $rule.get,
      actual: $itemMetadata.exists,
    )


func kinds*(
    itemMetadata: ItemMetadata,
    rule: ItemMetaDataRules.kinds
): RuleVerifierResult =
  if rule.isNone:
    return
  if itemMetadata.kind notin rule.get:
    result.isViolated = true
    result.violation = option (
      kind: ViolationKind.itemKinds,
      expected: $rule.get,
        actual: $itemMetadata.kind,
    )


func itemFullname*(
    itemMetadata: ItemMetadata,
    rule: ItemMetadataRules.itemFullname
): RuleVerifierResult =
  if rule.isNone:
    return
  if itemMetadata.fullName != rule.get:
    result.isViolated = true
    result.violation = option (
      kind: ViolationKind.itemFullname,
      expected: $rule.get,
      actual: itemMetadata.fullName,
    )
