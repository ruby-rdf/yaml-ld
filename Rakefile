require 'rubygems'

task default: [ :spec ]

namespace :gem do
  desc "Build the yaml-ld-#{File.read('VERSION').chomp}.gem file"
  task :build do
    sh "gem build yaml-ld.gemspec && mv yaml-ld-#{File.read('VERSION').chomp}.gem pkg/"
  end

  desc "Release the yaml-ld-#{File.read('VERSION').chomp}.gem file"
  task :release do
    sh "gem push pkg/yaml-ld-#{File.read('VERSION').chomp}.gem"
  end
end
