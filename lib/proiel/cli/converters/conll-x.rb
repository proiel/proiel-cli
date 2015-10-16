module PROIEL
  module Converter
    # This converts to the CoNLL-X format as described on http://ilk.uvt.nl/conll/#dataformat.
    class CoNLLX
      class << self
        def process(tb, options)
          tb.sources.each do |source|
            source.divs.each do |div|
              div.sentences.each do |sentence|
                id_to_number = {}

# probably an error here with prodroptokens, see conll-u script
                
                sentence.tokens.map(&:id).each_with_index.each do |id, i|
                  id_to_number[id] = i + 1
                end

                id_to_token = {}

                sentence.tokens.each do |token|
                  id_to_token[token.id] = token
                end

                sentence.tokens.each do |token|
                  unless token.is_empty?
                    this_number = id_to_number[token.id]
                    head_number, relation = find_lexical_head_and_relation(id_to_number, id_to_token, token)
                    form = token.form.gsub(' ', '')
                    lemma = token.lemma.gsub(' ', '')
                    pos_major = token.part_of_speech_hash.major
                    pos_full = token.part_of_speech
                    morphology = format_morphology(token)

                    puts [this_number, form, lemma, pos_major, pos_full,
                          morphology, head_number, relation, "_", "_"].join("\t")
                  end
                end

                puts
              end
            end
          end
        end

        def format_morphology(token)
          token.morphology_hash.to_h.map do |k, v|
            # Remove inflection tag unless when set to inflecting
            if k == :inflection and v =='i'
              nil
            else
              "#{k.upcase[0..3]}#{v}"
            end
          end.compact.join('|')
        end

        def find_lexical_head_and_relation(id_to_number, id_to_token, t, rel = '')
          if t.is_root?
            [0, rel + t.relation] # FIXME: may be empty token anyway
          elsif id_to_token[t.head_id].has_content?
            [id_to_number[t.head_id], rel + t.relation]
          else
            find_lexical_head_and_relation(id_to_number, id_to_token, id_to_token[t.head_id], rel + "#{t.relation}(#{id_to_number[t.head_id]})")
          end
        end
      end
    end
  end
end
