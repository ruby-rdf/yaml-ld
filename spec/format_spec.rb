# coding: utf-8
require_relative 'spec_helper'
require 'rdf/spec/format'

describe YAML_LD::Format do
  it_behaves_like 'an RDF::Format' do
    let(:format_class) {YAML_LD::Format}
  end

  describe ".for" do
    [
      :yamlld,
      "etc/doap.yamlld",
      {file_name:      'etc/doap.yamlld'},
      {file_extension: 'yamlld'},
      {content_type:   'application/ld+yaml'},
    ].each do |arg|
      it "discovers with #{arg.inspect}" do
        expect(RDF::Format.for(arg)).to eq described_class
      end
    end

    {
      yamlld:   %(---
        "@context": "foo"
      ),
      context:  %(---
        "@context": {
      ),
      id:       %(---
        "@id": "foo"
      ),
      type:       %(---
        "@type": "foo"
      ),
    }.each do |sym, str|
      it "detects #{sym}" do
        expect(described_class.for {str}).to eq described_class
      end
    end

    it "should discover 'yamlld'" do
      expect(RDF::Format.for(:yamlld).reader).to eq YAML_LD::Reader
    end
  end

  describe "#to_sym" do
    specify {expect(described_class.to_sym).to eq :yamlld}
  end

  describe "#to_uri" do
    specify {expect(described_class.to_uri).to eq RDF::URI('http://www.w3.org/ns/formats/YAML-LD')}
  end
end
