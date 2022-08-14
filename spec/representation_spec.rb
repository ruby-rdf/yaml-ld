# coding: utf-8
require_relative 'spec_helper'

describe YAML_LD::Representation do
  describe "load_stream" do
    {
      "Stream": {
        input: %(
          ---
          a
          ...
          ---
          b
          ...
        ),
        expected: %w(a b)
      },
      "String": {
        input: %(a),
        expected: %w(a)
      },
    }.each do |name, params|
      it name do
        input = params[:input]
        ir = YAML_LD::Representation.load_stream(input.unindent.strip)
        expected = params[:expected]
        expect(ir).to be_equivalent_structure expected
      end
    end
  end

  describe "load" do
    {
      "Stream": {
        input: %(
          ---
          a
          ...
          ---
          b
          ...
        ),
        expected: "a"
      },
      "Null": {
        input: %(null),
        expected: nil
      },
      "!!null null": {
        input: %(!!null null),
        expected: nil
      },
      "!<tag:yaml.org,2002:null> null": {
        input: %(!<tag:yaml.org,2002:null> null),
        expected: nil
      },
      "Boolean": {
        input: %(true),
        expected: true
      },
      "!!bool true": {
        input: %(!!bool true),
        expected: true
      },
      "!<tag:yaml.org,2002:bool> true": {
        input: %(!<tag:yaml.org,2002:bool> true),
        expected: true
      },
      "String": {
        input: %(a),
        expected: "a"
      },
      "Tagged !!str String": {
        input: %(!!str string),
        expected: "string"
      },
      "Tagged !<tag:yaml.org,2002:str> String": {
        input: %(!<tag:yaml.org,2002:str> string),
        expected: "string"
      },
      "Integer": {
        input: %(1),
        expected: 1
      },
      "Tagged !!int 1": {
        input: %(!!int 1),
        expected: 1
      },
      "Tagged !<tag:yaml.org,2002:int> 1": {
        input: %(!<tag:yaml.org,2002:int> 1),
        expected: 1
      },
      "Float": {
        input: %(1.0),
        expected: Float(1.0)
      },
      "Tagged !!float -1": {
        input: %(!!float -1),
        expected: Float(-1)
      },
      "Tagged !<tag:yaml.org,2002:float> 2.3e4": {
        input: %(!<tag:yaml.org,2002:float> 2.3e4),
        expected: Float(2.3e4)
      },
      "Tagged !<tag:yaml.org,2002:float> .inf": {
        input: %(!<tag:yaml.org,2002:float> .inf),
        expected: Float::INFINITY
      },
    }.each do |name, params|
      it name do
        input = params[:input]
        ir = YAML_LD::Representation.load(input.unindent.strip)
        expected = params[:expected]
        expect(ir).to be_equivalent_structure expected
      end
    end
  end
end
