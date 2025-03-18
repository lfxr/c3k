import
  sequtils

import
  rules,
  types,
  utils/[
    item,
    path
  ]


proc verify*(regulation: Regulation, globalIgnores: seq[string]): seq[ViolatingItem] =
  let selfItems: seq[Item] = regulation.path.matchingPaths.mapIt(newItem(it))
  let childItems: seq[Item] = (
    proc(): seq[Item] =
      for selfItem in selfItems:
        result = result.concat(selfItem.childItems)
  )()
  # let metaItemMetaDataSeq: seq[ItemMetaData] = @[
  #   (
  #     path: "/mnt/c/users/user/Downloads",
  #     itemType: dir,
  #     ext: "",
  #     subExt: "",
  #   ),
  # ]
  # let childItemMetaDataSeq: seq[ItemMetaData] = @[
  #   (
  #     path: "/mnt/c/users/user/Downloads/abc.txt",
  #     itemType: file,
  #     ext: "txt",
  #     subExt: "",
  #   ),
  # ]
  result.add(regulation.rules.selfRules.verify(selfItems))
  result.add(regulation.rules.childItemsRules.verify(childItems))
