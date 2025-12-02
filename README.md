# PROIEL command-line interface

## Status

[![Gem Version](https://badge.fury.io/rb/proiel-cli.svg)](http://badge.fury.io/rb/proiel-cli)
[![Build Status](https://secure.travis-ci.org/proiel/proiel-cli.svg?branch=master)](http://travis-ci.org/proiel/proiel-cli?branch=master)

## Description

This is a command-line interface for manipulating PROIEL treebanks.

## Installation

This library requires Ruby >= 2.4. Install as

```shell
gem install proiel-cli
```

## Using the command-line interface

This gem includes a command-line utility, `proiel`, which solves various routine tasks involving PROIEL-style treebanks.

`proiel info`, for example, displays metadata and some brief statistics, and `proiel convert conll` converts the treebank to CoNLL format. Use `proiel --help` for further examples and usage instructions.

To use the `visualize` command you will need to have [graphviz](http://graphviz.org) installed. On macOS you can use [Homebrew](https://brew.sh/) for this:

```shell
brew install graphviz
```

Make sure that the `dot` command is available in the path:

```shell
$ which dot
/usr/local/bin/dot
```

## Contributing

Bug reports and pull requests are welcome on [GitHub](https://github.com/proiel/proiel-cli/issues).

## Development

To contribute to development, check out the git repository from [GitHub](https://github.com/proiel/proiel-cli) and run `bundle install` to install all development dependencies. Then run `rake` to run the tests.

To install a development version of this gem, run `bundle exec rake install`.

### Releasing a new version

To release a new version:

1.  Update the version number in `lib/proiel/cli/version.rb`.
2.  Run `bundle exec rake release`. This will:
    *   Create a git tag for the version.
    *   Push git commits and tags to the remote repository.
    *   Push the `.gem` file to [rubygems.org](https://rubygems.org).
