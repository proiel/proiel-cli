# PROIEL CLI

This is a command-line interface for manpulating PROIEL treebanks.

## Installation

Install as

```shell
gem install proiel-cli
```

## Getting started

The recommended way to getting started is to use the `proiel` command-line
utility to create a new application:

```sh
proiel init myprojectname
```

This will take care of everything you need to get started, including
downloading the treebank data files.

Alternatively you can set things up manually. Minimally, you will need to
require the `proiel` gem in your application and load one or more treebank
files:

```ruby
require 'proiel'

tb = PROIEL::Treebank.new
tb.load_from_xml('caes-gal.xml')
```

One way of acquiring and managing the treebank files is to add
`proiel-treebank` as a git submodule:

```sh
mkdir vendor
git submodule add https://github.com/proiel/proiel-treebank.git vendor/proiel-treebank
```

See the [wiki](https://github.com/proiel/proiel-cli/wiki) for more information.

## Using the command-line interface

The gem includes a command-line utility `proiel` for a number of routine tasks.
`proiel info`, for example, displays metadata and some brief statistics, and
`proiel convert conll` converts the treebank to CoNLL format. Use `proiel
--help` for further examples and usage instructions.

## Development

Check out the git repository from github and run `bin/setup` to install
development dependencies. Then run `rake` to run the tests.

To install a development version of this gem, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the gem to
[rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/proiel/proiel-cli.
