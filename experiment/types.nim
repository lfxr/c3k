type ErrorKind* = enum
  invalidSizeSpecification,


type Error* = object of CatchableError
  case kind*: ErrorKind
  of invalidSizeSpecification:
    message*: string
