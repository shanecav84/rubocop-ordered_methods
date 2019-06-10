[![Gem Version](https://badge.fury.io/rb/rubocop-ordered_methods.svg)](https://badge.fury.io/rb/rubocop-ordered_methods)
[![Build Status](https://travis-ci.org/shanecav84/rubocop-ordered_methods.svg?branch=master)](https://travis-ci.org/shanecav84/rubocop-ordered_methods)

# RuboCop OrderedMethods

Check that methods are defined alphabetically. Note [caveats](#caveats) for
autocorrector.

```ruby
# bad
def self.b; end
def self.a; end

def b; end
def a; end

private

def d; end
def c; end

# good
def self.a; end
def self.b; end

def a; end
def b; end

private

def c; end
def d; end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rubocop-ordered_methods'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubocop-ordered_methods

## Usage

You need to tell RuboCop to load the OrderedMethods extension. There are two
ways to do this:

### RuboCop configuration file

Put this into your `.rubocop.yml`.

```
require: rubocop-ordered_methods
```

Now you can run `rubocop` and it will automatically load the RuboCop OrderedMethods
cops together with the standard cops.

### Command line

```bash
rubocop --require rubocop-ordered_methods
```

### Configurable attributes

Name | Default value | Configurable values
--- | --- | ---
EnforcedStyle | `alphabetical` | `alphabetical`
IgnoredMethods | `initialize` | Array

### Corrector

The corrector will attempt to order methods alphabetically. It attempts to
include surrounding comments and the qualifiers listed in
`::RuboCop::Cop::Layout::OrderedMethods::QUALIFIERS`.

#### Caveats
The corrector can fail to include surrounding comments and qualifiers for some
methods.

## Development

### Setup

```bash
bundle install
bundle exec rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/shanecav84/rubocop-ordered_methods. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuboCop OrderedMethods project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/shanecav84/rubocop-ordered_methods/blob/master/CODE_OF_CONDUCT.md).
