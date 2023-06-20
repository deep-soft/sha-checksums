# SHA checksums [![License](https://img.shields.io/github/license/deep-soft/sha-checksums)](https://github.com/deep-soft/sha-checsums/blob/master/LICENSE)
GitHub action that can be used to create SHA checksums for files.

It works on all platforms: **Linux**, **MacOS** and **Windows**.

Tested on macos-11, macos-12, macos-13, ubuntu-20.04, ubuntu-22.04, windows-2019, windows-2022.

Note: In Windows, the SHA checksums  created for text files ( *.txt *.sh *.c *.cpp *.yml ...) are different from the SHA checksum created in linux and macOS due to CR+LF vs CR or LF

## Usage
An example workflow config:
```yaml
name: Create SHA256 checksums
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@master
    - name: SHA256 checksums
      uses: deep-soft/sha-checksums@v1
      with:
        type: 'SHA256'
        filename: 'SHA256SUMS'
        directory: '.'
        path: 'release'
        ignore_git: false
```

The generated archive will be placed as specified by `directory`, `path` and `filename`.

## Arguments

### `filename`
Default: `SHA256SUMS`

The filename for the generated checksums, relative to `directory`.

### `directory`
Default: `.`

The working directory where the program runs.

### `path`
Default: `.`

The path to the files or directory for which checksums will be computed, relative to `directory`.

### `type`
Default: `SHA256`

`SHA1`, `SHA256`, `SHA512`

### `ignore_git`
Default: `true`

Ignore path ./git and ./.git/
