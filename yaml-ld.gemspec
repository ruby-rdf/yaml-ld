#!/usr/bin/env ruby -rubygems
# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.version               = File.read('VERSION').chomp
  gem.date                  = File.mtime('VERSION').strftime('%Y-%m-%d')

  gem.name                  = "yaml-ld"
  gem.homepage              = "https://github.com/ruby-rdf/yaml-ld"
  gem.license               = 'Unlicense'
  gem.summary               = "YAML-LD reader/writer for Ruby."
  gem.description           = "YAML_LD parses and serializes YAML-LD into RDF and implements expansion, compaction and framing API interfaces for the Ruby RDF.rb library suite."
  gem.metadata           = {
    "documentation_uri" => "https://ruby-rdf.github.io/yaml-ld",
    "bug_tracker_uri"   => "https://github.com/ruby-rdf/yaml-ld/issues",
    "homepage_uri"      => "https://github.com/ruby-rdf/yaml-ld",
    "mailing_list_uri"  => "https://lists.w3.org/Archives/Public/public-rdf-ruby/",
    "source_code_uri"   => "https://github.com/ruby-rdf/yaml-ld",
  }

  gem.authors               = ['Gregg Kellogg']
  gem.email                 = 'public-linked-json@w3.org'

  gem.platform              = Gem::Platform::RUBY
  gem.files                 = %w(AUTHORS README.md UNLICENSE VERSION) + Dir.glob('lib/**/*.rb')
  gem.bindir               = %q(bin)
  gem.require_paths         = %w(lib)
  gem.test_files            = Dir.glob('spec/**/*.rb') + Dir.glob('spec/test-files/*')

  gem.required_ruby_version = '>= 2.6'
  gem.requirements          = []
  gem.add_runtime_dependency     'json-ld',         '~> 3.2', '>= 3.2.3'
  gem.add_runtime_dependency     'psych',           '~> 4.0'
  gem.add_runtime_dependency     'rdf',             '~> 3.2', '>= 3.2.9'
  gem.add_development_dependency 'rdf-isomorphic',  '~> 3.2'
  gem.add_development_dependency 'rdf-spec',        '~> 3.2'
  gem.add_development_dependency 'rdf-trig',        '~> 3.2'
  gem.add_development_dependency 'rdf-turtle',      '~> 3.2'
  gem.add_development_dependency 'rdf-vocab',       '~> 3.2'
  gem.add_development_dependency 'rdf-xsd',         '~> 3.2'
  gem.add_development_dependency 'rspec',           '~> 3.10'
  gem.add_development_dependency 'rspec-its',       '~> 1.3'
  gem.add_development_dependency 'yard' ,           '~> 0.9'

  gem.post_install_message  = nil
end
