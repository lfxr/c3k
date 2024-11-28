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
requires "yaml == 2.1.1"
requires "regex == 0.25.0"
requires "unicodedb == 0.12.0"
requires "glob == 0.11.3"

requires "terminaltables == 0.1.1"
requires "cligen == 1.7.2"
requires "rainbow == 0.2.2"

# Tasks

task precommit, "Run all precommit tasks":
  exec "nimble markdownlint"
  exec "nimble typos"
  exec "nimble lslint"

task markdownlint, "Lint markdown files":
  exec "markdownlint-cli2 **/*.md"

task typos, "Check for typos":
  exec "typos"

task lslint, "Lint file and directory names":
  exec "ls-lint"
