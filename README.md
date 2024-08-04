# c3k

Linter for your disk.

## Motivation

- Keep Desktop and Downloads folders clean
  - No more installer files in Downloads by moving them to specific folders
  - Remain shortcut files, but disallow non-shortcut files
  - Or allow no files in Desktop so that you can see your wallpaper clearly
- Help your files to follow your own naming rules

## Features

- Detect files and folders that do not match the rules
- Rule
  - File name
  - Extension
  - Size
  - Action
    - Move to a specific folder
    - Delete
    - Rename

## Usage

### CLI

```sh
c3k scan
```

### Library

docs

## Installation

```sh
nimble install c3k
```

## CLI Tutorial

### Setup

```sh
# 1. Initialize setting file
c3k init

# 2. Edit the setting file to write your own rules
#    The setting file is located at ~/.config/c3k.setting.yaml by default.
#    e.g. edit with Neovim
nvim ~/.config/c3k/c3k.setting.yaml
```

### Scan

```sh
c3k scan
```

## Setting File

> [!TIP]
> Visit [Setting File Format](./setting_file_format.md) to learn more.

Here is a simple example:

```yaml
ignores:
  - desktop.ini

rules:
  ~/Desktop:
    ext: .lnk
  ~/Downloads:
    # Allows no items
    itemTypes: []
  ~/Pictures/**:
    fileName: $date
```
