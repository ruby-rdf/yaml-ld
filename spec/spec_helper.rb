$:.unshift(File.join("../../lib", __FILE__))
$:.unshift File.dirname(__FILE__)

require "bundler/setup"
require 'rspec'
require 'rdf'
require 'rdf/isomorphic'
require 'rdf/nquads'
require 'rdf/turtle'
require 'rdf/trig'
require 'rdf/vocab'
require 'rdf/spec'
require 'rdf/spec/matchers'
require_relative 'matchers'
require 'yaml'
begin
  require 'simplecov'
  require 'simplecov-lcov'
  SimpleCov::Formatter::LcovFormatter.config do |config|
    #Coveralls is coverage by default/lcov. Send info results
    config.report_with_single_file = true
    config.single_report_path = 'coverage/lcov.info'
  end

  SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new([
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ])
  SimpleCov.start do
    add_filter "/spec/"
  end
rescue LoadError
end

require 'yaml_ld'

# Left-justifies a block string
class ::String
  def unindent
    self.gsub(/^#{self.scan(/^[ \t]+(?=\S)/).min}/, '')
  end
end

# Heuristically detect the input stream
def detect_format(stream)
  # Got to look into the file to see
  if stream.respond_to?(:rewind) && stream.respond_to?(:read)
    stream.rewind
    string = stream.read(1000)
    stream.rewind
  else
    string = stream.to_s
  end
  case string
  when /<html/i           then RDF::RDFa::Reader
  when /\{\s*\"@\"/i      then JSON::LD::Reader
  else                         RDF::Turtle::Reader
  end
end

# Creates a bijection between the two objects and replaces nodes in actual from expected.
def remap_bnodes(actual, expected)
  # Transform each to RDF and perform a blank node bijection.
  # Replace the blank nodes in action with the mapping from bijection.
  ds_actual = RDF::Repository.new << JSON::LD::API.toRdf(actual, rdfstar: true, rename_bnodes: false)
  ds_expected = RDF::Repository.new << JSON::LD::API.toRdf(expected, rdfstar: true, rename_bnodes: false)
  if bijection = ds_actual.bijection_to(ds_expected)
    bijection = bijection.inject({}) {|memo, (k, v)| memo.merge(k.to_s => v.to_s)}

    # Recursively replace blank nodes in actual with the bijection
    replace_nodes(actual, bijection)
  else
    actual
  end
end

def replace_nodes(object, bijection)
  case object
  when Array
    object.map {|o| replace_nodes(o, bijection)}
  when Hash
    object.inject({}) do |memo, (k, v)|
      memo.merge(bijection.fetch(k, k) => replace_nodes(v, bijection))
    end
  when String
    bijection.fetch(object, object)
  else
    object
  end
end

LIBRARY_INPUT = JSON.parse(%([
  {
    "@id": "http://example.org/library",
    "@type": "http://example.org/vocab#Library",
    "http://example.org/vocab#contains": {"@id": "http://example.org/library/the-republic"}
  }, {
    "@id": "http://example.org/library/the-republic",
    "@type": "http://example.org/vocab#Book",
    "http://purl.org/dc/elements/1.1/creator": "Plato",
    "http://purl.org/dc/elements/1.1/title": "The Republic",
    "http://example.org/vocab#contains": {
      "@id": "http://example.org/library/the-republic#introduction",
      "@type": "http://example.org/vocab#Chapter",
      "http://purl.org/dc/elements/1.1/description": "An introductory chapter on The Republic.",
      "http://purl.org/dc/elements/1.1/title": "The Introduction"
    }
  }
]))

LIBRARY_EXPANDED = JSON.parse(%([
  {
    "@id": "http://example.org/library",
    "@type": ["http://example.org/vocab#Library"],
    "http://example.org/vocab#contains": [{"@id": "http://example.org/library/the-republic"}]
  }, {
    "@id": "http://example.org/library/the-republic",
    "@type": ["http://example.org/vocab#Book"],
    "http://purl.org/dc/elements/1.1/creator": [{"@value": "Plato"}],
    "http://purl.org/dc/elements/1.1/title": [{"@value": "The Republic"}],
    "http://example.org/vocab#contains": [{
      "@id": "http://example.org/library/the-republic#introduction",
      "@type": ["http://example.org/vocab#Chapter"],
      "http://purl.org/dc/elements/1.1/description": [{"@value": "An introductory chapter on The Republic."}],
      "http://purl.org/dc/elements/1.1/title": [{"@value": "The Introduction"}]
    }]
  }
]))

LIBRARY_COMPACTED_DEFAULT = JSON.parse(%({
  "@context": "http://schema.org",
  "@graph": [
    {
      "id": "http://example.org/library",
      "type": "http://example.org/vocab#Library",
      "http://example.org/vocab#contains": {"id": "http://example.org/library/the-republic"}
    }, {
      "id": "http://example.org/library/the-republic",
      "type": "http://example.org/vocab#Book",
      "http://purl.org/dc/elements/1.1/creator": "Plato",
      "http://purl.org/dc/elements/1.1/title": "The Republic",
      "http://example.org/vocab#contains": {
        "id": "http://example.org/library/the-republic#introduction",
        "type": "http://example.org/vocab#Chapter",
        "http://purl.org/dc/elements/1.1/description": "An introductory chapter on The Republic.",
        "http://purl.org/dc/elements/1.1/title": "The Introduction"
      }
    }
  ]
}))

LIBRARY_COMPACTED = JSON.parse(%({
  "@context": "http://conneg.example.com/context",
  "@graph": [
    {
      "@id": "http://example.org/library",
      "@type": "ex:Library",
      "ex:contains": {
        "@id": "http://example.org/library/the-republic"
      }
    },
    {
      "@id": "http://example.org/library/the-republic",
      "@type": "ex:Book",
      "dc:creator": "Plato",
      "dc:title": "The Republic",
      "ex:contains": {
        "@id": "http://example.org/library/the-republic#introduction",
        "@type": "ex:Chapter",
        "dc:description": "An introductory chapter on The Republic.",
        "dc:title": "The Introduction"
      }
    }
  ]
}))

LIBRARY_FLATTENED_EXPANDED = JSON.parse(%([
  {
    "@id": "http://example.org/library",
    "@type": ["http://example.org/vocab#Library"],
    "http://example.org/vocab#contains": [{"@id": "http://example.org/library/the-republic"}]
  },
  {
    "@id": "http://example.org/library/the-republic",
    "@type": ["http://example.org/vocab#Book"],
    "http://purl.org/dc/elements/1.1/creator": [{"@value": "Plato"}],
    "http://purl.org/dc/elements/1.1/title": [{"@value": "The Republic"}],
    "http://example.org/vocab#contains": [{"@id": "http://example.org/library/the-republic#introduction"}]
  },
  {
    "@id": "http://example.org/library/the-republic#introduction",
    "@type": ["http://example.org/vocab#Chapter"],
    "http://purl.org/dc/elements/1.1/description": [{"@value": "An introductory chapter on The Republic."}],
    "http://purl.org/dc/elements/1.1/title": [{"@value": "The Introduction"}]
  }
]))

LIBRARY_FLATTENED_COMPACTED_DEFAULT = JSON.parse(%({
  "@context": "http://schema.org",
  "@graph": [
    {
      "id": "http://example.org/library",
      "type": "http://example.org/vocab#Library",
      "http://example.org/vocab#contains": {"id": "http://example.org/library/the-republic"}
    },
    {
      "id": "http://example.org/library/the-republic",
      "type": "http://example.org/vocab#Book",
      "http://purl.org/dc/elements/1.1/creator": "Plato",
      "http://purl.org/dc/elements/1.1/title": "The Republic",
      "http://example.org/vocab#contains": {"id": "http://example.org/library/the-republic#introduction"}
    },
    {
      "id": "http://example.org/library/the-republic#introduction",
      "type": "http://example.org/vocab#Chapter",
      "http://purl.org/dc/elements/1.1/description": "An introductory chapter on The Republic.",
      "http://purl.org/dc/elements/1.1/title": "The Introduction"
    }
  ]
}))

LIBRARY_FLATTENED_COMPACTED = JSON.parse(%({
  "@context": "http://conneg.example.com/context",
  "@graph": [
    {
      "@id": "http://example.org/library",
      "@type": "ex:Library",
      "ex:contains": {"@id": "http://example.org/library/the-republic"}
    },
    {
      "@id": "http://example.org/library/the-republic",
      "@type": "ex:Book",
      "dc:creator": "Plato",
      "dc:title": "The Republic",
      "ex:contains": {"@id": "http://example.org/library/the-republic#introduction"}
    },
    {
      "@id": "http://example.org/library/the-republic#introduction",
      "@type": "ex:Chapter",
      "dc:description": "An introductory chapter on The Republic.",
      "dc:title": "The Introduction"
    }
  ]
}))

LIBRARY_FRAMED = JSON.parse(%({
  "@context": {
    "dc": "http://purl.org/dc/elements/1.1/",
    "ex": "http://example.org/vocab#"
  },
  "@id": "http://example.org/library",
  "@type": "ex:Library",
  "ex:contains": {
    "@id": "http://example.org/library/the-republic",
    "@type": "ex:Book",
    "dc:creator": "Plato",
    "dc:title": "The Republic",
    "ex:contains": {
      "@id": "http://example.org/library/the-republic#introduction",
      "@type": "ex:Chapter",
      "dc:description": "An introductory chapter on The Republic.",
      "dc:title": "The Introduction"
    }
  }
}))
