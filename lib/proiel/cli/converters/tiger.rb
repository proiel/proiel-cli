require 'builder'

module PROIEL
  module Converter
    # Converter for the TigerXML format
    # (http://www.ims.uni-stuttgart.de/projekte/TIGER/TIGERSearch/doc/html/TigerXML.html)
    # in the variant used by VISL under the name 'TIGER dependency format'
    # (http://beta.visl.sdu.dk/treebanks.html#TIGER_dependency_format).
    class Tiger
      SCHEMA_FILE = File.join('tigerxml', 'TigerXML.xsd')

      MORPHOLOGICAL_FEATURES = %i(person_number tense_mood_voice case_number gender degree strength inflection)
      OTHER_FEATURES = %i(lemma pos information_status antecedent_id word)

      class << self
        def process(tb, options)
          @ident = 'id'

          ## FIXME: what if there is a conflict between features
          selected_features = MORPHOLOGICAL_FEATURES + OTHER_FEATURES

          # FIXME: we don't yet support semantic features in PROIEL XML 2
          #@semantic_features = SemanticAttribute.all.map(&:tag).map(&:downcase).map(&:to_sym)
          #selected_features += @semantic_features if @options[:sem_tags]

          @features = selected_features.map { |f| [f, 'FREC'] }.to_h

          builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
          builder.instruct! :xml, version: "1.0", encoding: "UTF-8"

          tb.sources.each do |source|
            @hack = tb.annotation_schema
            write_source(builder, source) do
              source.divs.each do |div|
                div.sentences.each do |sentence|
                  write_sentence(builder, sentence)
                end
              end
            end
          end
        end

        def write_source(builder, s)
          builder.corpus(id: s.id) do
            builder.head do
              builder.meta do
                builder.name(s.title)
              end

              declare_annotation(builder, @features, @hack)
            end

            builder.body do
              yield
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

        def token_attrs(s, t, type)
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
                  attrs[name] = t.empty_token_sort + "-"
                else
                  attrs[name] = t.pos
                end
              when *MORPHOLOGICAL_FEATURES
                attrs[name] = name.to_s.split("_").map { |a| t.send(a.to_sym).nil? ? "-" : t.send(a.to_sym) }.join
              else
                if t.respond_to?(name)
                  attrs[name] = t.send(name)
                else
                  raise "Do not know how to get required attribute #{name}"
                end
              end
              attrs[name] ||= "--"
            end
          end

          attrs
        end

        def write_terminals(builder, s)
          builder.terminals do
            s.tokens.each do |t|
              builder.t(token_attrs(s, t, 'T').merge({ @ident => "w#{t.id}"}))
            end
          end
        end

        def write_nonterminals(builder, s)
          builder.nonterminals do
            # Add an empty root node
            h = @features.select { |_, domain| ['FREC', 'NT'].include?(domain) }.map { |name, _| [name, '--'] }.to_h
            h[@ident] = "s#{s.id}_root"

            builder.nt(h) do
              s.tokens.reject { |t| t.head or t.pro? }.each do |t|
                builder.edge(idref: "p#{t.id}", label: t.relation)
              end
            end

            # Add other NTs
            s.tokens.each do |t|
              builder.nt(token_attrs(s, t, 'NT').merge(@ident => "p#{t.id}")) do
                # Add an edge to the correspoding terminal node
                builder.edge(idref: "w#{t.id}", label: '--')

                # Add primary dependency edges
                t.children.each { |d| builder.edge(idref: "p#{d.id}", label: d.relation) }

                # Add secondary dependency edges
                t.slashes.each do |se|
                  builder.secedge(idref: "p#{se.target_id}", label: se.relation)
                end
              end
            end
          end
        end

        def write_sentence(builder, s)
          builder.s(id: "s#{s.id}") do
            builder.graph(root: "s#{s.id}_root") do
              write_terminals(builder, s)
              write_nonterminals(builder, s)
            end
          end
        end
      end
    end
  end
end
