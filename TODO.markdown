Lister TODO
===========

Bugs
---

- (FIXED) Explodes in edgecase with "Error writing file: Broken pipe (Errno)"
  replicate with: `lister | tee /dev/null | tail -1`

Planned
-------

### Themer

- (DONE) Allow themes to have fallback colors for different color depths
- Specify theme on commandline
- Specify theme in config file
- Sepcify color depth on commandline
- Sepcify color depth in config file
- Attempt to autodetect color depth if not specified
- true color palette names
- Integrate XKCD's rgb.txt

### Visual

- flag executable files somehow
- Tree-like line-drawing characters option for indentation

### Output Options

- Option to list only files of a given type
- Option to group files by type
- Option to list directories first or last
- Option to display shortened formatting output (names+colors only)
- Option to display creation/modification/access times
- Option to display unix attributes user/group/r/w/x

### Future

- When Crystal supports Windows, make the PATH_SEP autodetect

