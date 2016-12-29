Lister TODO
===========

Bugs
---

- Explodes in edgecase with "Error writing file: Broken pipe (Errno)"
  replicate with: `lister | tee /dev/null | tail -1`

Planned
-------

- Tree-like line-drawing characters option for indentation
- Option to list only files of a given type
- Option to group files by type
- Option to list directories first or last
- Option to display shortened formatting output (names+colors only)
- Option to display creation/modification/access times
- Option to display unix attributes user/group/r/w/x
- flag executable files somehow
- Extended color palettes (256/True Color)
- Configurable themes
- When Crystal supports Windows, make the PATH_SEP autodetect
