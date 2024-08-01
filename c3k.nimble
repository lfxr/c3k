# Package

version       = "0.1.0"
author        = "lafixier"
description   = "A new awesome nimble package"
license       = "Proprietary"
srcDir        = "src"
installExt    = @["nim"]
bin           = @["c3k"]


# Dependencies

requires "nim >= 2.0.2"
requires "regex == 0.25.0"
requires "unicodedb == 0.12.0"
requires "glob == 0.11.3"

requires "terminaltables == 0.1.1"
requires "cligen == 1.7.2"
requires "rainbow == 0.2.2"
