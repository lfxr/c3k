import
  unittest

import
  ../../../src/c3k/parse_setting,
  ../../../src/c3k/types


block:
  check "<10B".parseSize == (
    comparisonOperator: lessThan,
    size: 10,
    unit: DataUnit.byte,
  )
  check "<10KiB".parseSize == (
    comparisonOperator: lessThan,
    size: 10,
    unit: kibibyte,
  )
  check "<10MiB".parseSize == (
    comparisonOperator: lessThan,
    size: 10,
    unit: mebibyte,
  )
  check "<10GiB".parseSize == (
    comparisonOperator: lessThan,
    size: 10,
    unit: gibibyte,
  )

block:
  check "<=10B".parseSize == (
    comparisonOperator: lessThanOrEqual,
    size: 10,
    unit: DataUnit.byte,
  )
  check "<=10KiB".parseSize == (
    comparisonOperator: lessThanOrEqual,
    size: 10,
    unit: kibibyte,
  )
  check "<=10MiB".parseSize == (
    comparisonOperator: lessThanOrEqual,
    size: 10,
    unit: mebibyte,
  )
  check "<=10GiB".parseSize == (
    comparisonOperator: lessThanOrEqual,
    size: 10,
    unit: gibibyte,
  )

block:
  check ">10B".parseSize == (
    comparisonOperator: greaterThan,
    size: 10,
    unit: DataUnit.byte,
  )
  check ">10KiB".parseSize == (
    comparisonOperator: greaterThan,
    size: 10,
    unit: kibibyte,
  )
  check ">10MiB".parseSize == (
    comparisonOperator: greaterThan,
    size: 10,
    unit: mebibyte,
  )
  check ">10GiB".parseSize == (
    comparisonOperator: greaterThan,
    size: 10,
    unit: gibibyte,
  )

block:
  check ">=10B".parseSize == (
    comparisonOperator: greaterThanOrEqual,
    size: 10,
    unit: DataUnit.byte,
  )
  check ">=10KiB".parseSize == (
    comparisonOperator: greaterThanOrEqual,
    size: 10,
    unit: kibibyte,
  )
  check ">=10MiB".parseSize == (
    comparisonOperator: greaterThanOrEqual,
    size: 10,
    unit: mebibyte,
  )
  check ">=10GiB".parseSize == (
    comparisonOperator: greaterThanOrEqual,
    size: 10,
    unit: gibibyte,
  )
