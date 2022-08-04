source "https://rubygems.org"

gemspec
gem 'rdf',              git: "https://github.com/ruby-rdf/rdf",            branch: "develop"
gem 'json-ld',          git: "https://github.com/ruby-rdf/json-ld",        branch: "develop"

group :development do
  gem 'rdf-isomorphic', git: "https://github.com/ruby-rdf/rdf-isomorphic", branch: "develop"
  gem 'rdf-spec',       git: "https://github.com/ruby-rdf/rdf-spec",       branch: "develop"
  gem 'rdf-vocab',      git: "https://github.com/ruby-rdf/rdf-vocab",      branch: "develop"
  gem 'rdf-xsd',        git: "https://github.com/ruby-rdf/rdf-xsd",        branch: "develop"
  gem 'earl-report'
  gem 'ruby-prof',  platforms: :mri
end

group :development, :test do
  gem 'simplecov', '~> 0.21',  platforms: :mri
  gem 'simplecov-lcov', '~> 0.8',  platforms: :mri
  gem 'rake'
end

group :debug do
  gem "byebug", platforms: :mri
end
