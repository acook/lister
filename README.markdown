Lister
======

A commandline program which lists, sorts, filters and displays files and directories.

Lister can be used to get more information about your files or just to present it differently.

Lister can supplement or even replace `ls` for day-to-day commandline tasks.

Killer Features
---------------

### It's magic!

What sets Lister apart from standard `ls` is that it's magic! I mean, it's libMagic. It guesses the type of the file by its "magic number" or file contents instead of just by file extension. 

### It's colorful!

Lister supports 16 million colors in it's output. Seriously. And most modern terminal emulators [support it](https://gist.github.com/XVilka/8346728). It also supports 256 extended colors and standard 16 colors if you want to have a fallback just in case, or maybe you want to keep synchrony with your terminal palette. 

### It's configurable!

You can make your own themes!<sup>[*](#wip)</sup> And a whole lot more [is planned](https://github.com/acook/lister/blob/master/TODO.markdown).

Installation
============

As soon as a few more things are squared away I'll upload binary releases for macOS and Linux, but for now you can compile it yourself.

If you're using [Homebrew](https://brew.sh) or [Linuxbrew](https://linuxbrew.sh) all you need to do is `brew install crystal` and then run `./scripts/build` and then put the resulting binary (`./bin/lister`) somewhere in your `$PATH`. You can even make an alias for it if you want a shorter name (I recomend `alias l=lister`).

If you're not using \*brew then follow the instructions on the [Crystal homepage](https://crystal-lang.org) 
[Crystal](https://crystal-lang.org) to install it and then `./scripts/build`!

> Copyright 2016 - Anthony M. Cook



<a name="wip">*</a>: Some things are a work in progress!
