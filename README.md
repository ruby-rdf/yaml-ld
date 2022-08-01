# YAML-LD reader/writer

Ruby [YAML-LD][] reader/writer for RDF.rb

[![Gem Version](https://badge.fury.io/rb/yaml-ld.png)](https://rubygems.org/gems/yaml-ld)
[![Build Status](https://secure.travis-ci.org/ruby-rdf/yaml-ld.png?branch=develop)](https://github.com/ruby-rdf/yaml-ld/actions?query=workflow%3ACI)
[![Coverage Status](https://coveralls.io/repos/ruby-rdf/yaml-ld/badge.svg?branch=develop)](https://coveralls.io/github/ruby-rdf/yaml-ld?branch=develop)
[![Gitter chat](https://badges.gitter.im/ruby-rdf.png)](https://gitter.im/gitterHQ/gitter)

## Features

YAML_LD parses and serializes [YAML-LD][] into [RDF][].

As the specification is under development, this gem should be considered **experimental** and is subject to change at any time.

YAML-LD documents may use frames or contexts described either using [JSON-LD][] or [YAML-LD][].

* Process YAML-LD source using JSON-LD Context or Frame.
* Process JSON-LD source using YAML-LD Context or Frame.

### Profiles

The specification defines both basic and extended profiles. This gem is limited to the basic profile at this time.

## Implementation

The gem largely acts as a front-end for the [JSON-LD gem][] with differences largely in the serialization format only.

## Dependencies
* [Ruby](https://ruby-lang.org/) (>= 2.6)
* [RDF.rb](https://rubygems.org/gems/rdf) (~> 3.2)
* [JSON](https://rubygems.org/gems/json) (>= 2.6)

## Installation
The recommended installation method is via [RubyGems](https://rubygems.org/).
To install the latest official release of the `JSON-LD` gem, do:

    % [sudo] gem install yaml-ld

## Download
To get a local working copy of the development repository, do:

    % git clone git://github.com/ruby-rdf/yaml-ld.git

## Mailing List
* <https://lists.w3.org/Archives/Public/public-rdf-ruby/>

## Author
* [Gregg Kellogg](https://github.com/gkellogg) - <https://greggkellogg.net/>

## Contributing
* Do your best to adhere to the existing coding conventions and idioms.
* Don't use hard tabs, and don't leave trailing whitespace on any line.
* Do document every method you add using [YARD][] annotations. Read the
  [tutorial][YARD-GS] or just look at the existing code for examples.
* Don't touch the `json-ld.gemspec`, `VERSION` or `AUTHORS` files. If you need to
  change them, do so on your private branch only.
* Do feel free to add yourself to the `CREDITS` file and the corresponding
  list in the the `README`. Alphabetical order applies.
* Do note that in order for us to merge any non-trivial changes (as a rule
  of thumb, additions larger than about 15 lines of code), we need an
  explicit [public domain dedication][PDD] on record from you,
  which you will be asked to agree to on the first commit to a repo within the organization.
  Note that the agreement applies to all repos in the [Ruby RDF](https://github.com/ruby-rdf/) organization.

## License

This is free and unencumbered public domain software. For more information,
see <https://unlicense.org/> or the accompanying {file:UNLICENSE} file.

[Ruby]:             https://ruby-lang.org/
[RDF]:              https://www.w3.org/RDF/
[YARD]:             https://yardoc.org/
[YARD-GS]:          https://rubydoc.info/docs/yard/file/docs/GettingStarted.md
[PDD]:              https://unlicense.org/#unlicensing-contributions
[RDF.rb]:           https://rubygems.org/gems/rdf
[JSON-LD gem]:          https://rubygems.org/gems/json-ld
[JSON-LD]:          https://www.w3.org/TR/json-ld11/ "JSON-LD 1.1"
[JSON-LD API]:      https://www.w3.org/TR/json-ld11-api/ "JSON-LD 1.1 Processing Algorithms and API"
[JSON-LD Framing]:  https://www.w3.org/TR/json-ld11-framing/ "JSON-LD 1.1 Framing"
[YAML-LD]:          https://json-ld.github.io/yaml-ld/spec/
