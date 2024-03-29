module PROIEL::Converter
  # Converter that outputs PROIEL XML. This is primarily useful for filtering,
  # merging or splitting PROIEL XML data. It is also useful for "upgrading"
  # PROIEL XML to a new version or for testing round tripping of data.
  class PROIELXML
    class << self
      def process(tb, options)
        builder = Builder::XmlMarkup.new(target: STDOUT, indent: 2)
        builder.instruct! :xml, version: '1.0', encoding: 'UTF-8'
        builder.proiel('export-time' => DateTime.now.xmlschema, 'schema-version' => '2.1') do
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
            next if options['remove-unaligned-sources'] and source.alignment_id.nil?

            mandatory_features = %i(id language)
            optional_features = []
            optional_features += %i(alignment_id) unless options['remove-alignments']

            builder.source(grab_features(source, mandatory_features, optional_features)) do
              PROIEL::Treebank::METADATA_ELEMENTS.each do |field|
                builder.tag!(field.to_s.gsub('_', '-'), source.send(field)) if source.send(field)
              end

              source.divs.each do |div|
                if include_div?(div, options)

                  overrides = {
                    div: {},
                    sentence: {},
                    token: {}
                  }

                  process_div(builder, tb, source, div, options, overrides)
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
        when :reviewed
          not options['remove-reviewed'] and not options['remove-annotated']
        when :annotated
          not options['remove-not-reviewed'] and not options['remove-annotated']
        else
          not options['remove-not-reviewed'] and not options['remove-not-annotated']
        end
      end

      def include_token?(token, options)
        if options['remove-syntax'] and (token.empty_token_sort == 'C' or token.empty_token_sort == 'V')
          false
        elsif token.empty_token_sort == 'P' and options['remove-information-structure']
          false
        else
          true
        end
      end

      def process_div(builder, tb, source, div, options, overrides)
        mandatory_features = %i()

        optional_features = []
        optional_features += %i(presentation_before presentation_after)
        optional_features += %i(id alignment_id) unless options['remove-alignments']

        if options['infer-alignments'] and source.alignment_id
          aligned_source = tb.find_source(source.alignment_id)
          # FIXME: how to behave here? overwrite existing? what if nil? how to deal with multiple aligned divs?
          overrides[:div][:alignment_id] = div.alignment_id || div.inferred_alignment(aligned_source).map(&:id).join(',')
        end

        builder.div(grab_features(div, mandatory_features, optional_features, overrides[:div])) do
          builder.title div.title if div.title

          div.sentences.select do |sentence|
            include_sentence?(sentence, options)
          end.each do |sentence|
            process_sentence(builder, tb, sentence, options, overrides)
          end
        end
      end

      def process_sentence(builder, tb, sentence, options, overrides)
        mandatory_features = %i(id)

        optional_features = [] # we do it this way to preserve the order of status and presentation_* so that diffing files is easier
        optional_features += %i(status) unless options['remove-status']
        optional_features += %i(presentation_before presentation_after)
        optional_features += %i(alignment_id) unless options['remove-alignments']
        optional_features += %i(annotated_at) unless options['remove-annotator']
        optional_features += %i(reviewed_at) unless options['remove-reviewer']
        optional_features += %i(annotated_by) unless options['remove-annotator']
        optional_features += %i(reviewed_by) unless options['remove-reviewer']

        builder.sentence(grab_features(sentence, mandatory_features, optional_features)) do
          sentence.tokens.select do |token|
            include_token?(token, options)
          end.each do |token|
            process_token(builder, tb, token, options, overrides)
          end
        end
      end

      def process_token(builder, tb, token, options, overrides)
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

        if options['remove-not-reviewed'] or options['remove-not-annotated'] or options['remove-annotated'] or options['remove-annotated']
          overrides[:token][:antecedent_id] =
            (token.antecedent_id and include_sentence?(tb.find_token(token.antecedent_id.to_i).sentence, options)) ? token.antecedent_id : nil
        end

        optional_features += %i(alignment_id) unless options['remove-alignments']

        attrs = grab_features(token, mandatory_features, optional_features, overrides[:token])

        unless token.slashes.empty? or options['remove-syntax'] # this extra test avoids <token></token> style XML
          builder.token(attrs) do
            token.slashes.each do |relation, target_id|
              builder.slash(:"target-id" => target_id, relation: relation)
            end
          end
        else
          unless options['remove-syntax'] and token.is_empty?
            builder.token(attrs)
          end
        end
      end

      def grab_features(obj, mandatory_features, optional_features = [], overrides = {})
        attrs = {}

        mandatory_features.each do |f|
          v = overrides.key?(f) ? overrides[f] : obj.send(f)

          attrs[f.to_s.gsub('_', '-')] = v
        end

        optional_features.each do |f|
          v = overrides.key?(f) ? overrides[f] : obj.send(f)

          if v and v.to_s != ''
            attrs[f.to_s.gsub('_', '-')] = v
          end
        end

        attrs
      end
    end
  end
end
