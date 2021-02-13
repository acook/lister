Lister
======

Lister is a little directory lister that does filetype analysis!

[![CircleCI](https://img.shields.io/circleci/build/github/acook/lister?style=for-the-badge)](https://app.circleci.com/pipelines/github/acook/lister)

Killer Features
---------------

Lister can be used to get more information about your files or just to present it differently.

### It's magic!

What sets Lister apart from standard `ls` is that it's magic! I mean it's `libMagic`. It guesses the type of the file by its "magic number" or file contents instead of just by file extension.

### It's colorful!

Lister supports 16 million colors in it's output. Seriously. And most modern terminal emulators [support it](https://gist.github.com/XVilka/8346728). It also supports 256 extended colors and standard 16 colors if you want to have a fallback just in case, or maybe you want to keep synchrony with your terminal palette.

### It's configurable!

You can make your own themes!

Just export the internal theme so you don't have to start from scratch:

~~~shell
$ lister --colors-export ~/my_new_theme.yml
~~~

Then modify the colors to your hearts content!

And you can make Lister always use your color theme by setting an environment variable:

~~~shell
$ export LISTER_THEME=~/my_new_theme.yml
~~~

You could also create a shorter alias and select your color theme like this:

~~~shell
$ alias l=lister --colors my_new_theme.yml
~~~

This also means you can create multiple aliases with different themes for different use cases!

Usage
=====

~~~shell
lister 0.1.0
Anthony M. Cook <github@anthonymcook.com>
http://github.com/acook/lister

lister is a file and directory listing utility which shows colorized and structured libmagic types.

USAGE:
	lister [OPTIONS] [PATH ...]
	lister --colors-export PATH
	lister --colors-list

OPTIONS:
	--			stop processing commandline options and interpret remaining arguments as paths
	-A			show hidden files (excluding . and ..)
	--colors FILE		use specified YAML file as color theme
	--colors-export FILE	export internal color theme as YAML file
	--colors-list		display list of known themeable file types in the associated color from the current theme
	--color-depth DEPTH	use the 16, 256, or true color palette
	-h			display usage information (you're looking at it!)
	-K			show type names as seen by Lister
	-Km			show MIME types from libMagic
	-R			recurse infinite
	--recurse DEPTH		recurse to depth
	<paths>			a list of zero or more paths will scan PWD if no path supplied

ENVIRONMENT:
	LISTER_COLORS		full path to the Lister theme YAML file, can be overridden on the commandline with --colors
~~~

Building
========

You'll need a copy of the code:
- `git clone https://github.com/acook/lister`
- `cd lister`

The setup script will install `crystal` for you if you're on a system with `brew` or `apt`:
- `./scripts/setup`

Run the build script:
- `./scripts/build`

Put the resulting binary somewhere in your path:
- `mv bin/lister ~/bin/`

Created By
=========

> Copyright 2016-2021 - Anthony M. Cook
