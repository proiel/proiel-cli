# PROIEL command-line interface

This is a command-line interface for manpulating PROIEL treebanks.

## Installation

This library requires Ruby >= 2.1. Install as

```shell
gem install proiel-cli
```

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
