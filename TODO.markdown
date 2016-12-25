Lister TODO
===========

`whatkind` Parity
-----------------

- Figure out the terminal width and truncate long lines
  Crystal lacks Array#pack, so the Ruby code won't work.
  https://github.com/crystal-lang/crystal/issues/276

Bugs
---

- Causes redraw issues with subsequent `less`/`more` and `vim`

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
