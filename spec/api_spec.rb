
# coding: utf-8
require_relative 'spec_helper'

describe YAML_LD::API do
  let(:logger) {RDF::Spec.logger}
  before {JSON::LD::Context::PRELOADED.clear}

  context "Test Files" do
    %i(psych).each do |adapter|
      Dir.glob(File.expand_path(File.join(File.dirname(__FILE__), 'test-files/*-input.*'))) do |filename|
        test = File.basename(filename).sub(/-input\..*$/, '')
        frame = filename.sub(/-input\..*$/, '-frame.jsonld')
        framed = filename.sub(/-input\..*$/, '-framed.jsonld')
        compacted = filename.sub(/-input\..*$/, '-compacted.jsonld')
        context = filename.sub(/-input\..*$/, '-context.jsonld')
        expanded = filename.sub(/-input\..*$/, '-expanded.jsonld')
        expanded_yaml = filename.sub(/-input\..*$/, '-expanded.yamlld')
        ttl = filename.sub(/-input\..*$/, '-rdf.ttl')

        context test do
          around do |example|
            @file = File.open(filename)
            case filename
            when /\.yamlld$/
              @file.define_singleton_method(:content_type) {'application/ld+yaml'}
            when /.jsonld$/
              @file.define_singleton_method(:content_type) {'application/ld+json'}
            end
            if context
              @ctx_io = File.open(context)
              case context
              when /\.yamlld$/
                @ctx_io.define_singleton_method(:content_type) {'application/ld+yaml'}
              when /.jsonld$/
                @ctx_io.define_singleton_method(:content_type) {'application/ld+json'}
              end
            end
            example.run
            @file.close
            @ctx_io.close if @ctx_io
          end

          if File.exist?(expanded)
            it "expands" do
              options = {logger: logger, adapter: adapter}
              options[:expandContext] = @ctx_io if context
              yaml = described_class.expand(@file, **options)
              expect(yaml).to be_a(String)
              parsed_json = JSON.load_file(expanded)
              expect(yaml).to produce_yamlld(parsed_json, logger)
            end
          end

          if File.exist?(expanded_yaml)
            it "expands to YAML" do
              options = {logger: logger, adapter: adapter}
              options[:expandContext] = @ctx_io if context
              yaml = described_class.expand(@file, **options)
              expect(yaml).to be_a(String)
              expect(yaml).to produce_yamlld(YAML.load_file(expanded_yaml), logger)
            end
          end

          if File.exist?(compacted) && File.exist?(context)
            it "compacts" do
              yaml = described_class.compact(@file, @ctx_io, adapter: adapter, logger: logger)
              expect(yaml).to be_a(String)
              parsed_json = JSON.load_file(compacted)
              expect(yaml).to produce_yamlld(parsed_json, logger)
            end
          end

          if File.exist?(framed) && File.exist?(frame)
            it "frames" do
              File.open(frame) do |frame_io|
                yaml = described_class.frame(@file, frame_io, adapter: adapter, logger: logger)
                expect(yaml).to be_a(String)
                parsed_json = JSON.load_file(framed)
                expect(yaml).to produce_yamlld(parsed_json, logger)
              end
            end
          end

          it "toRdf" do
            expect(RDF::Repository.load(filename, format: :yamlld, adapter: adapter, logger: logger)).to be_equivalent_graph(RDF::Repository.load(ttl), logger: logger)
          end if File.exist?(ttl)
        end
      end
    end
  end
end
