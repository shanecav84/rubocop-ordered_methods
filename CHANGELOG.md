# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.13] - 2024-10-01

### Fixed

- Fix clobbering when consecutive nodes are with wrong order [#17](https://github.com/shanecav84/rubocop-ordered_methods/pull/17). Thanks, @Darhazer.

## [0.12] - 2024-07-16

### Fixed

- Add MethodQualifiers to the default config [#13](https://github.com/shanecav84/rubocop-ordered_methods/pull/13). Thanks, @Darhazer.
- Fix rubocop 1.65 compatability [#16](https://github.com/shanecav84/rubocop-ordered_methods/pull/16). Thanks, @Darhazer.

## [0.11] - 2023-12-19

### Fixed

- Fix handling require at the top of the file, nil nodes, and nodes that aren't of type AST::node ([#15](https://github.com/shanecav84/rubocop-ordered_methods/pull/15)). Thanks @rohitpaulk and @libmartinito

## [0.10] - 2021-03-10

### Removed

- Drop support for Ruby 2.4, 2.5, and 2.6

### Added

- Support for custom method qualifiers ([#11](https://github.com/shanecav84/rubocop-ordered_methods/pull/11)). Thanks @Darhazer.
- Setup CI ([#12](https://github.com/shanecav84/rubocop-ordered_methods/pull/12)). Thanks @Darhazer.

## [0.9] - 2021-03-10

### Added

- Autocorrection support for Sorbet signatures

## [0.8] - 2021-02-01

### Fixed

- Fix NoMethodError and the "\[Correctable\]" label ([#6](https://github.com/shanecav84/rubocop-ordered_methods/pull/6)). Thanks @jaredbeck.

## [0.7] - 2021-01-11

### Removed

- Drop Ruby 2.3 support
- Drop support for rubocop < 1.0

### Changed

- Support for rubocop >= 1.0 ([#5](https://github.com/shanecav84/rubocop-ordered_methods/pull/5)). Thanks @jaredbeck.

## [0.6] - 2020-03-01

### Security

- Upgrade rake to avoid vulnerability https://cve.mitre.org/cgi-bin/cvename.cgi?name=CVE-2020-8130
    - rake is a development dependency for this gem, so shouldn't have been a risk for production

## [0.5] - 2019-11-05

### Removed

- Drop Ruby 2.2 support

### Changed

- Nonadjacent qualifiers are now autocorrected (#4). Thanks @adamkiczula.
- Cache AST traversals for significant speed up on large files

## [0.4] - 2019-06-11

### Changed

- More robust autocorrection of a method and its surroundings (see `Corrector` in the `README`).

## [0.3] - 2019-02-17

### Added

- Configuration defaults

## [0.2] - 2019-02-17

### Added

- Autocorrector

## [0.1] - 2019-02-17

Initial release.

[Unreleased]: https://github.com/shanecav84/rubocop-ordered_methods/compare/v0.3...HEAD
[0.3]: https://github.com/shanecav84/rubocop-ordered_methods/compare/v0.2...v0.3
[0.2]: https://github.com/shanecav84/rubocop-ordered_methods/compare/v0.1...v0.2
[0.1]: https://github.com/shanecav84/rubocop-ordered_methods/releases/tag/v0.1
