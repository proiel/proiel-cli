module PROIEL
  module Converter
    class Tiger2
      SCHEMA_FILE = File.join('tiger2', 'Tiger2.xsd')

      class << self
        def process(tb, options)
#          super(source, options)

selected_features = [] # TODO
          @features = selected_features.map { |f| [f, 'FREC'] }
#          @features.delete_if { |o| o.first == 'antecedent_id' }
#          @ident = 'xml:id'

          builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
          builder.instruct! :xml, version: "1.0", encoding: "UTF-8"

          tb.sources.each do |source|
            @hack = tb.annotation_schema
            write_source(builder, source, tb) do
              source.divs.each do |div|
                div.sentences.each do |sentence|
                  write_sentence(builder, sentence)
                end
              end
            end
          end
        end

        def write_source(builder, s, tb)
          builder.corpus('xml:id' => s.id,
                        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
                        'xsi:schemaLocation' => 'http://korpling.german.hu-berlin.de/tiger2/V2.0.5/ http://korpling.german.hu-berlin.de/tiger2/V2.0.5/Tiger2.xsd',
                        'xmlns:tiger2' => 'http://korpling.german.hu-berlin.de/tiger2/V2.0.5/',
                        'xmlns' => 'http://korpling.german.hu-berlin.de/tiger2/V2.0.5/') do
            builder.head do
              builder.meta do
                builder.name(s.title)
                builder.author('The PROIEL project')
                builder.date(Time.now)
                builder.description
                builder.format
                builder.history
              end

              PROIEL::Converter::Tiger.declare_annotation(builder, @features, tb)
            end

            builder.body do
              yield builder
            end
          end
        end

        def declare_edgelabels(builder)
          builder.feature(name: "label", type: "prim", domain: "edge") do
            declare_primary_edges(builder)
          end

          builder.feature(name: "label", type: "sec", domain: "edge") do
            declare_secedges(builder)
          end

          builder.feature(name: "label", type: "coref", domain: "edge") do
            builder.value(name: "antecedent")
            builder.value(name: "inference")
          end
        end

        def write_sentence(builder, s)
          builder.s('xml:id' => "s#{s.id}") do
            builder.graph(root: "s#{s.id}_root") do
              PROIEL::Converter::Tiger.write_terminals(builder, s)
              PROIEL::Converter::Tiger.write_nonterminals(builder, s) if s.has_dependency_annotation?
            end
          end
        end

        def write_root_edge(t, builder)
          builder.edge('tiger2:type' => "prim", 'tiger2:target' => "p#{t.id}", :label => t.relation.tag)
        end

        def write_edges(t, builder)
          # Add an edge between this node and the correspoding terminal node unless
          # this is not a morphtaggable node.
          builder.edge('tiger2:type' => "prim", 'tiger2:target' => "w#{t.id}", :label => '--') if t.is_morphtaggable? or t.empty_token_sort == 'P'

          # Add primary dependency edges including empty pro tokens if we are exporting info structure as well
          t.dependents.each { |d| builder.edge('tiger2:type' => "prim", 'tiger2:target' => "p#{d.id}", :label => d.relation.tag) }

          # Add secondary dependency edges
          get_slashes(t).each do |se|
            builder.edge('tiger2:type' => "sec", 'tiger2:target' => "p#{se.slashee_id}", :label => se.relation.tag)
          end

          builder.edge('tiger2:type' => "coref", 'tiger2:target' => t.antecedent_id, :label => (t.information_status_tag == 'acc_inf' ? "inference" : "antecedent") )
        end
      end
    end
  end
end
