module PROIEL
  module Converter
    class PROIELXML
      class << self
        def process(tb, options)
          builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
          builder.instruct! :xml, version: '1.0', encoding: 'UTF-8'
          builder.proiel('export-time' => DateTime.now.xmlschema, 'schema-version' => '2.0') do
            builder.annotation do
              builder.relations do
                tb.annotation_schema.relation_tags.each do |tag, value|
                  attrs = { tag: tag }
                  attrs.merge!(grab_features(value, %i(summary primary secondary)))
                  builder.value(attrs)
                end
              end

              builder.tag! 'parts-of-speech' do
                tb.annotation_schema.part_of_speech_tags.each do |tag, value|
                  attrs = { tag: tag }
                  attrs.merge!(grab_features(value, %i(summary)))
                  builder.value(attrs)
                end
              end

              builder.morphology do
                tb.annotation_schema.morphology_tags.each do |cat_tag, cat_values|
                  builder.field(tag: cat_tag) do
                    cat_values.each do |tag, value|
                      attrs = { tag: tag }
                      attrs.merge!(grab_features(value, %i(summary)))
                      builder.value(attrs)
                    end
                  end
                end
              end

              builder.tag! 'information-statuses' do
                tb.annotation_schema.information_status_tags.each do |tag, value|
                  attrs = { tag: tag }
                  attrs.merge!(grab_features(value, %i(summary)))
                  builder.value(attrs)
                end
              end
            end

            tb.sources.each do |source|
              builder.source(id: source.id, language: source.language) do
                PROIEL::Treebank::METADATA_ELEMENTS.each do |field|
                  builder.tag!(field.gsub('_', '-'), source.send(field)) if source.send(field)
                end

                source.divs.each do |div|
                  if include_div?(div, options)
                    builder.div(grab_features(div, %i(), %i(presentation_before presentation_after))) do
                      builder.title div.title if div.title

                      div.sentences.each do |sentence|
                        if include_sentence?(sentence, options)
                          mandatory_features = %i(id)

                          optional_features = [] # we do it this way to preserve the order of status and presentation_* so that diffing files is easier
                          optional_features += %i(status) unless options['remove-status']
                          optional_features += %i(presentation_before presentation_after)

                          builder.sentence(grab_features(sentence, mandatory_features, optional_features)) do
                            sentence.tokens.each do |token|
                              next if token.empty_token_sort == 'P' and options['remove-information-structure']
                              next if token.empty_token_sort == 'C' and options['remove-syntax']
                              next if token.empty_token_sort == 'V' and options['remove-syntax']

                              mandatory_features = %i(id)

                              optional_features = %i(citation_part)
                              optional_features += %i(lemma part_of_speech morphology) unless options['remove-morphology']
                              optional_features += %i(head_id relation) unless options['remove-syntax']
                              optional_features += %i(antecedent_id information_status contrast_group) unless options['remove-information-structure']

                              unless token.is_empty?
                                mandatory_features << :form
                                optional_features += %i(presentation_before presentation_after foreign_ids)
                              else
                                mandatory_features << :empty_token_sort
                              end

                              attrs = grab_features(token, mandatory_features, optional_features)

                              unless token.slashes.empty? or options['remove-syntax'] # this extra test avoids <token></token> style XML
                                builder.token(attrs) do
                                  token.slashes.each do |relation, target_id|
                                    builder.slash(target_id: target_id, relation: relation)
                                  end
                                end
                              else
                                unless options['remove-syntax'] and token.is_empty?
                                  builder.token(attrs)
                                end
                              end
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end

        def include_div?(div, options)
          if options['remove-empty-divs']
            div.sentences.any? { |sentence| include_sentence?(sentence, options) }
          else
            true
          end
        end

        def include_sentence?(sentence, options)
          case sentence.status
          when 'reviewed'
            true
          when 'annotated'
            not options['remove-not-reviewed']
          else
            not options['remove-not-reviewed'] and not options['remove-not-annotated']
          end
        end

        def grab_features(obj, mandatory_features, optional_features = [])
          attrs = {}

          mandatory_features.each do |f|
            v = obj.send(f)

            attrs[f.to_s.gsub('_', '-')] = v
          end

          optional_features.each do |f|
            v = obj.send(f)

            if v and v.to_s != ''
              attrs[f.to_s.gsub('_', '-')] = v
            end
          end

          attrs
        end
      end
    end
  end
end
