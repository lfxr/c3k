# Setting File Format <!-- omit in toc -->

- [ignores](#ignores)
- [rules](#rules)
  - [Path](#path)
  - [Rule](#rule)
  - [Value Types](#value-types)
    - [Size](#size)
      - [Operator](#operator)
      - [Size](#size-1)
      - [Unit](#unit)

The setting file consists of two sections: `ignores` and `rules`.

```yaml
ignores:
  # …
rules:
  # …
```

## ignores

File names or directory names to ignore.

Example:

```yaml
ignores:
  - desktop.ini
  - .git
  - node_modules
```

## rules

Pairs of path and rule for it.

```yaml
rules:
  {path}:
    {ruleKey}: {value}
    # …
  {path}:
    {ruleKey}: {value}
    # …
  # …
```

Example:

```yaml
rules:
  ~/Desktop:
    ext: .lnk
  ~/Downloads:
    itemSize: <1MiB
  ~/Pictures/**:
    ext: .(jpg|png)
```

### Path

Glob patterns can be used.

### Rule

| Rule Key       | Limits what?             | Value Type        | Value Examples        |
| -------------- | ------------------------ | ----------------- | --------------------- |
| `itemType`     | item type (file, dir)    | List<file\|dir>   | `[file]`              |
| `itemFullname` | item name with extension | String (regex)    | `img_\d+.(jpg\|png)`  |
| `itemName`     | item name                | String (regex)    | `img_\d+`             |
| `ext`          | extension                | String (regex)    | `.lnk`, `.(jpg\|png)` |
| `itemSize`     | item size                | String (**Size**) | `>1KiB`, `<=5MiB`     |
| `fileFullname` | file name with extension | String (regex)    | `img_\d+.(jpg\|png)`  |
| `fileName`     | file name                | String (regex)    | `img_\d+`             |
| `fileSize`     | file size                | String (**Size**) | `>1KiB`, `<=5MiB`     |
| `dirName`      | directory name           | String (regex)    | `downloads_\d+`       |
| `dirSize`      | directory size           | String (**Size**) | `>1KiB`, `<=5MiB`     |

### Value Types

#### Size

format: `{operator}{size}{unit}`

examples: `>1KiB`, `<5MiB`

##### Operator

| Operator | Description              |
| -------- | ------------------------ |
| `<`      | less than                |
| `<=`     | less than or equal to    |
| `>`      | greater than             |
| `>=`     | greater than or equal to |
| `==`     | equal to                 |

##### Size<!--(Value Types)-->

integer like `1`, `5`, `100`

##### Unit

| Unit  | Description |
| ----- | ----------- |
| `B`   | Byte        |
| `KiB` | Kibibyte    |
| `MiB` | Mebibyte    |
| `GiB` | Gibibyte    |
