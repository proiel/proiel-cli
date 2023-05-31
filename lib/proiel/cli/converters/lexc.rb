module PROIEL::Converter
  # Converter that outputs a lexc file with part of speech and morphology.
  class Lexc
    class << self
      def process(tb, options)
        lexicon = {}

        tb.sources.each do |source|
          source.divs.each do |div|
            div.sentences.each do |sentence|
              sentence.tokens.each do |token|
                unless token.is_empty?
                  lexicon[token.form] ||= []
                  if options['morphology']
                    lexicon[token.form] << [token.lemma, [token.part_of_speech, token.morphology].join].join(',')
                  else
                    lexicon[token.form] << [token.lemma, token.part_of_speech].join(',')
                  end
                end
              end
            end
          end
        end

        puts 'LEXICON Root'
        lexicon.sort.each do |form, tags|
          tags.sort.uniq.each do |tag|
            puts '  %s:%s #;' % [tag, form]
          end
        end
      end
    end
  end
end
