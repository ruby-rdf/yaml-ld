# coding: utf-8
require_relative 'spec_helper'

describe YAML_LD do
  describe "test suite" do
    require_relative 'suite_helper'
    m = Fixtures::SuiteTest::Manifest.open("#{Fixtures::SuiteTest::SUITE}manifest.jsonld")
    describe m.name do
      m.entries.each do |t|
        specify "#{t.property('@id')}: #{t.name} #{t.positiveTest? ? 'unordered' : '(negative test)'}" do
          t.options[:ordered] = false
          expect{t.run self}.not_to write.to(:error)
        end

        specify "#{t.property('@id')}: #{t.name} ordered" do
          t.options[:ordered] = true
          expect {t.run self}.not_to write.to(:error)
        end if t.positiveTest?
      end
    end
  end
end unless ENV['CI']