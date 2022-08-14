# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'psych'
require 'rdf/xsd'

module YAML_LD
  ##
  # Transforms a Psych AST to the JSON-LD (extended) Internal Representation build using `Psych.parse`, `.parse_stream`, or `parse_file`.
  #
  # FIXME: Aliases
  module Representation
    ###
    # Load multiple documents given in +yaml+.  Returns the parsed documents
    # as a list.  If a block is given, each document will be converted to Ruby
    # and passed to the block during parsing
    #
    # @example
    #
    #   load_stream("--- foo\n...\n--- bar\n...") # => ['foo', 'bar']
    #
    #   list = []
    #   load_stream("--- foo\n...\n--- bar\n...") do |ruby|
    #     list << ruby
    #   end
    #   list # => ['foo', 'bar']
    #
    # @param [String] yaml
    # @param [String] filename
    # @param [Object] fallback
    # @param [Hash{Symbol => Object}] options
    # @return [Array<Object>]
    def load_stream(yaml, filename: nil, fallback: [], **options)
      result = if block_given?
        Psych.parse_stream(yaml, filename: filename) do |node|
          yield as_jsonld_ir(node, **options)
        end
      else
        as_jsonld_ir(Psych.parse_stream(yaml, filename: filename), **options)
      end

      result.is_a?(Array) && result.empty? ? fallback : result
    end
    module_function :load_stream

    ##
    # Load a single document from +yaml+.
    # @param (see load_stream)
    # @return [Object]
    def load(yaml, filename: nil, fallback: nil, **options)
      result = if block_given?
        load_stream(yaml, filename: filename, **options) do |node|
          yield node.first
        end
      else
        load_stream(yaml, filename: filename, **options).first
      end

      result || fallback
    end
    module_function :load

    ##
    # Transform a Psych::Nodes::Node to the JSON-LD Internal Representation
    #
    # @param [Psych::Nodes::Node] node
    # @param [Hash{Symbol => Object}] options
    # @option options [Boolean] :xsd (false)
    #   Scan nodes with an XMLSchema tag as an `RDF::Literal`
    # @option options [Boolean] :i18n (false)
    #   Scan nodes with an I18N tag as an `RDF::Literal` with either datatype or language.
    # @return [Object]
    def as_jsonld_ir(node, **options)
      # Scans scalars for built-in classes
      @ss ||= Psych::ScalarScanner.new(Psych::ClassLoader::Restricted.new([], %i()))
      case node
      when Psych::Nodes::Stream
        node.children.map {|n| as_jsonld_ir(n, **options)}
      when Psych::Nodes::Document then as_jsonld_ir(node.children.first, **options)
      when Psych::Nodes::Sequence then node.children.map {|n| as_jsonld_ir(n, **options)}
      when Psych::Nodes::Mapping
        node.children.each_slice(2).inject({}) do |memo, (k,v)|
          memo.merge(as_jsonld_ir(k) => as_jsonld_ir(v, **options))
        end
      when ::Psych::Nodes::Scalar then scan_scalar(node, **options)
      when ::Psych::Nodes::Alias
        # FIXME
      end
    end
    module_function :as_jsonld_ir

    ##
    # Scans a scalar value to a JSON-LD IR scalar value
    #
    # @param [Psych::Nodes::Scalar] node
    # @param [Hash{Symbol => Object}] options
    # @option options [Boolean] :xsd (false)
    #   Scan nodes with an XMLSchema tag as an `RDF::Literal`
    # @option options [Boolean] :i18n (false)
    #   Scan nodes with an I18N tag as an `RDF::Literal` with either datatype or language.
    # @return [Object]
    def scan_scalar(node, **options)
      @ss ||= self.class.scalar_scanner
      case node.tag
      when "", NilClass
        # Tokenize, but prohibit certain types
        case node.value
          # Don't scan some scalar values to types other than string
        when Psych::ScalarScanner::TIME,
             /^\d{4}-(?:1[012]|0\d|\d)-(?:[12]\d|3[01]|0\d|\d)$/, # Date
             /^[-+]?[0-9][0-9_]*(:[0-5]?[0-9]){1,2}$/, # Time to seconds
             /^[-+]?[0-9][0-9_]*(:[0-5]?[0-9]){1,2}\.[0-9_]*$/ # Time to seconds
          node.value
        else
           @ss.tokenize(node.value)
        end
      when '!str', 'tag:yaml.org,2002:str'
        node.value
      when '!int', 'tag:yaml.org,2002:int'
        Integer(node.value)
      when "!float", "tag:yaml.org,2002:float"
        Float(@ss.tokenize(node.value))
      when "!null", "tag:yaml.org,2002:null"
        nil
      when "!bool", "tag:yaml.org,2002:bool"
        node.value.downcase == 'true'
      when %r(^http://www.w3.org/2001/XMLSchema)
        tag = node.tag
        if md = tag.match(%r(^http://www.w3.org/2001/XMLSchema(\w+)$))
          # Hack until YAML parsers scan %TAG URIs properly
          tag = "http://www.w3.org/2001/XMLSchema##{md[1]}"
        end
        options[:xsd] ?
          RDF::Literal(node.value, datatype: RDF::URI(tag), validate: true) :
          node.value
      when %r(^https://www.w3.org/ns/i18n)
        l_d = node.tag[26..-1]
        l_d = l_d[1..-1] if l_d.start_with?('#')
        l, d = l_d.split('_')
        if !@options[:i18n]
          node.value
        elsif d.nil?
          # Just use language component
          RDF::Literal(node.value, language: l)
        else
          # Language and direction
          RDF::Literal(node.value, datatype: RDF::URI("https://www.w3.org/ns/i18n##{l_d}"))
        end
      else
        raise ArgumentError, "Unsupported YAML tag #{node.tag}: #{node.value}"
      end
    end
    module_function :scan_scalar

    ##
    # Build a YAML AST with an RDF::Literal visitor
    #
    #
    #   builder = Psych::Visitors::YAMLTree.new
    #   builder << { :foo => 'bar' }
    #   builder.tree # => #<Psych::Nodes::Stream .. }
    #   builder.tree.yaml # => "..."
    class IRTree < Psych::Visitors::YAMLTree
      ##
      # Adds the `:xsd` and `:i18n` options for creating and parsing an XMLSchema tag and `RDF::Literal` scalar values
      def initialize emitter, ss, options
        super
      end

      ##
      # Add the object to be emitted. If the `:extended` option is set when the visitor is created, tags are added to the document.
      def push object
        start unless started?
        version = []
        version = [1,1] if @options[:header]

        case @options[:version]
        when Array
          version = @options[:version]
        when String
          version = @options[:version].split('.').map { |x| x.to_i }
        else
          version = [1,1]
        end if @options.key? :version

        @emitter.start_document version, [%w(!xsd! http://www.w3.org/2001/XMLSchema#)], false
        accept object
        @emitter.end_document !@emitter.streaming?
      end
      alias :<< :push

      ##
      # Emit an RDF Literal. If `extended` is set, use the datatype as an tag,
      # otherwise, emit in expanded form.
      def visit_RDF_Literal o
        tag = case o.datatype
        when nil then nil
        when RDF::XSD.string then nil
        when RDF.langString
          "https://www.w3.org/ns/i18n##{o.language}" if @options[:i18n]
        else
          if o.datatype.to_s.start_with?('https://www.w3.org/ns/i18n#')
            o.datatype.to_s if @options[:i18n]
          elsif @options[:xsd]
            o.datatype.to_s
          else
            nil
          end
        end
        formatted = o.value
        register o, @emitter.scalar(formatted, nil, tag, false, false, Psych::Nodes::Scalar::PLAIN)
      end
    end
  end
end