Lister TODO
===========

Bugs
---

- (FIXED) Explodes in edgecase with "Error writing file: Broken pipe (Errno)"
  replicate with: `lister | tee /dev/null | tail -1`

Planned
-------

### Core
- Handle missing libmagic database
- (DONE) Include libmagic database in binary
- Option to follow links
- Option to display filesize
- Option to display file analysis
  - audio files (tag info, length, etc)
  - image files (metadata)
- Option to pull specific information already available (such as color depth, sample rate, etc)
- Option to sort or filter by certain info
- Option to display attributes, extended attributes, resource forks, alternate data streams

### Themer

- (DONE) Allow themes to have fallback colors for different color depths
- (DONE) Specify theme on commandline
- Specify theme in config file
- (DONE) Sepcify color depth on commandline
- Specify color depth in config file
- Attempt to autodetect color depth if not specified
- true color palette names
- Integrate XKCD's rgb.txt

### Visual

- (DONE) flag executable files somehow
- Tree-like line-drawing characters option for indentation
- Don't display "ERROR" when gz finds a zip file confusing
- Include webp files as images
- Allow different sigils to have different colors?
- Integrate with git to display info about the directory/files?

### Output Options

- Option to list only files of a given type
- Option to group files by type
- Option to list directories first or last
- Option to display shortened formatting output (names+colors only)
- Option to display creation/modification/access times
- Option to display unix attributes user/group/r/w/x
- Option to disable zip profiling

### Future

- When Crystal supports Windows, make the PATH_SEP autodetect

