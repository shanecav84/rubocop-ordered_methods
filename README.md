[![Gem Version](https://badge.fury.io/rb/rubocop-ordered_methods.svg)](https://badge.fury.io/rb/rubocop-ordered_methods)
[![Build Status](https://travis-ci.org/shanecav84/rubocop-ordered_methods.svg?branch=master)](https://travis-ci.org/shanecav84/rubocop-ordered_methods)

# RuboCop OrderedMethods

Check that methods are defined alphabetically per access modifier block (class, 
public, private, protected). Includes [autocorrection](#corrector).

```ruby
# bad
def self.b_class; end
def self.a_class; end

def b_public; end
def a_public; end

private

def b_private; end
def a_private; end

# good
def self.a_class; end
def self.b_class; end

def a_public; end
def b_public; end

private

def a_private; end
def b_private; end
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
EnforcedStyle | `'alphabetical'` | `'alphabetical'`
IgnoredMethods | `['initialize']` | Array
MethodQualifiers | `[]` | Array
Signature | `nil` | `'sorbet'`, `nil`

#### Example

```
# .rubocop.yml
Layout/OrderedMethods:
  EnforcedStyle: alphabetical
  IgnoredMethods:
    - initialize
  MethodQualifiers:
    - memoize
  Signature: sorbet
```

### Corrector

The corrector will attempt to order methods based on the `EnforcedStyle`. It attempts to
include surrounding comments and the qualifiers (e.g., aliases) listed in
`::RuboCop::Cop::OrderedMethodsCorrector::QUALIFIERS`. The following (monstrous)
source is able to be correctly ordered:

```ruby
# Long
# Preceding
# Comment
# class_b
def self.class_b; end
private_class_method :class_b

def self.class_a; end
# Long
# Succeeding
# Comment
# class_a
public_class_method :class_a

# Preceding comment for instance_b
def instance_b; end
# Long
# Succeeding
# Comment
# instance_b
alias_method :orig_instance_b, :instance_b
module_function :instance_b
private :instance_b
protected :instance_b
public :instance_b

# Long
# Preceding
# Comment
# instance_a
def instance_a; end
# Succeeding comment for instance_a
alias :new_instance_a :instance_a
alias_method :orig_instance_a, :instance_a
module_function :instance_a
private :instance_a
protected :instance_a
public :instance_a
```

#### Method qualifiers
Some gems (like `memery`, `memoist`, etc.) provide a DSL that modifies the method (e.g. for memoization).
Those DSL methods can be added to the `MethodQualifiers` configuration, and they will be respected.

E.g. the following source can be correctly ordered:
```ruby
def b; end;
memoize def a;end
```

#### Method signatures

Support for (Sorbet) method signatures was added to the corrector by
[#7](https://github.com/shanecav84/rubocop-ordered_methods/pull/7).
It is off by default due to performance concerns (not yet benchmarked). Enable
with `Signature: sorbet`.

#### Caveats

* The corrector will warn and refuse to order a method if it were to be
  defined before its alias
* If there's ambiguity about which method a comment or qualifier belongs to,
  the corrector might fail to order correctly. For example, in the following, 
  the corrector would incorrectly order the comment as a comment of `a`:

  ```ruby
  def b; end
  # Comment b
  def a; end
  ```

## Development

### Setup

```bash
bundle install
bundle exec rake
```

## Contributing

Bug reports and pull requests are welcome on GitHub at 
https://github.com/shanecav84/rubocop-ordered_methods. This project is intended 
to be a safe, welcoming space for collaboration, and contributors are expected 
to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of
 conduct.

## License

The gem is available as open source under the terms of the 
[MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the RuboCop OrderedMethods project’s codebases, issue 
trackers, chat rooms and mailing lists is expected to follow the 
[code of conduct](https://github.com/shanecav84/rubocop-ordered_methods/blob/master/CODE_OF_CONDUCT.md).
