module PROIEL::Converter
  class Tiger2
    SCHEMA_FILE = File.join('tiger2', 'Tiger2.xsd')

    class << self
      def process(tb, _)
        selected_features = [] # TODO
        @features = selected_features.map { |f| [f, 'FREC'] }

        builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
        builder.instruct! :xml, version: '1.0', encoding: 'UTF-8'

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
              builder.date(s.export_time.strftime('%F %T %z'))
              builder.description
              builder.format
              builder.history
            end

            declare_annotation(builder, @features,
              tb.annotation_schema)
          end

          builder.body do
            yield builder
          end
        end
      end

      def declare_annotation(builder, features, annotation_schema)
        builder.annotation do
          features.each do |name, domain|
            # FIXME: we may want to list possible values for some of these
            builder.feature(name: name, domain: domain)
          end

          builder.edgelabel do
            builder.value(name: '--')

            annotation_schema.primary_relations.each do |tag, features|
              builder.value({ name: tag }, features.summary)
            end
          end

          builder.secedgelabel do
            annotation_schema.secondary_relations.each do |tag, features|
              builder.value({name: tag }, features.summary)
            end
          end
        end
      end

      def declare_edgelabels(builder)
        builder.feature(name: 'label', type: 'prim', domain: 'edge') do
          declare_primary_edges(builder)
        end

        builder.feature(name: 'label', type: 'sec', domain: 'edge') do
          declare_secedges(builder)
        end

        builder.feature(name: 'label', type: 'coref', domain: 'edge') do
          builder.value(name: 'antecedent')
          builder.value(name: 'inference')
        end
      end

      def write_sentence(builder, s)
        builder.s('xml:id' => "s#{s.id}") do
          builder.graph(root: "s#{s.id}_root") do
            write_terminals(builder, s)
            write_nonterminals(builder, s)
          end
        end
      end

      def write_terminals(builder, s)
        builder.terminals do
          s.tokens.each do |t|
            builder.t(token_attrs(t, 'T').merge({ 'xml:id' => "w#{t.id}"}))
          end
        end
      end

      def token_attrs(t, type)
        attrs = {}

        @features.each do |name, domain|
          if domain == 'FREC' or domain == type
            case name
            when :word, :cat
              attrs[name] = t.pro? ? "PRO-#{t.relation.upcase}" : t.form
            when *@semantic_features
              attrs[name] = t.sem_tags_to_hash[attr]
            when :lemma
              attrs[name] = t.lemma
            when :pos
              if t.empty_token_sort
                attrs[name] = t.empty_token_sort + '-'
              else
                attrs[name] = t.pos
              end
            when *MORPHOLOGICAL_FEATURES
              attrs[name] = name.to_s.split('_').map { |a| t.morphology_hash[a.to_sym] || '-' }.join
            else
              if t.respond_to?(name)
                attrs[name] = t.send(name)
              else
                raise "Do not know how to get required attribute #{name}"
              end
            end
            attrs[name] ||= '--'
          end
        end

        attrs
      end

      def write_nonterminals(builder, s)
        builder.nonterminals do
          # Add an empty root node
          h = @features.select { |_, domain| ['FREC', 'NT'].include?(domain) }.map { |name, _| [name, '--'] }.to_h
          h['xml:id'] = "s#{s.id}_root"

          builder.nt(h) do
            s.tokens.reject { |t| t.head or t.pro? }.each do |t|
              builder.edge(idref: "p#{t.id}", label: t.relation)
            end
          end

          # Add other NTs
          s.tokens.each do |t|
            builder.nt(token_attrs(t, 'NT').merge('xml:id' => "p#{t.id}")) do
              # Add an edge to the correspoding terminal node
              builder.edge(idref: "w#{t.id}", label: '--')

              # Add primary dependency edges
              t.children.each { |d| builder.edge(idref: "p#{d.id}", label: d.relation) }

              # Add secondary dependency edges
              t.slashes.each do |relation, target_id|
                builder.secedge(idref: "p#{target_id}", label: relation)
              end
            end
          end
        end
      end

      def write_root_edge(t, builder)
        builder.edge('tiger2:type' => 'prim', 'tiger2:target' => "p#{t.id}", :label => t.relation.tag)
      end

      def write_edges(t, builder)
        # Add an edge between this node and the correspoding terminal node unless
        # this is not a morphtaggable node.
        builder.edge('tiger2:type' => 'prim', 'tiger2:target' => "w#{t.id}", :label => '--') if t.is_morphtaggable? or t.empty_token_sort == 'P'

        # Add primary dependency edges including empty pro tokens if we are exporting info structure as well
        t.dependents.each { |d| builder.edge('tiger2:type' => 'prim', 'tiger2:target' => "p#{d.id}", :label => d.relation.tag) }

        # Add secondary dependency edges
        get_slashes(t).each do |se|
          builder.edge('tiger2:type' => 'sec', 'tiger2:target' => "p#{se.slashee_id}", :label => se.relation.tag)
        end

        builder.edge('tiger2:type' => 'coref', 'tiger2:target' => t.antecedent_id, :label => (t.information_status_tag == 'acc_inf' ? 'inference' : 'antecedent'))
      end
    end
  end
end
