module PROIEL
  module Commands
    class Grep < Command
      class << self
        def init_with_program(prog)
          prog.command(:grep) do |c|
            c.syntax 'grep [options] pattern filename(s)'
            c.description 'Search the text'

            c.option 'level', '--level LEVEL', 'Select level to match. LEVEL should be "token" or "sentence" (default)'
            c.option 'nostrip', '--nostrip', 'Do not strip whitespace from start and beginning of strings'
            c.option 'nosubst', '--nosubst', 'Do not substitute whitespace sequences with a single space'
            c.option 'nocolour', '--nocolour', 'Do not colour code matches'
            c.option 'ignore-case', '-i', '--ignore-case', 'Ignore uppercase/lowercase'

            c.action { |args, options| process(args, options) }
          end
        end

        def match(s, citation, object_id, pattern, options)
          s.strip! unless options['nostrip']
          s.gsub!(/\s+/, ' ') unless options['nosubst']

          if s[pattern]
            s.gsub!(pattern) { |m| m.yellow } unless options['nocolour']

            puts "#{citation} (ID = #{object_id}) #{s}"
          end
        end

        def merge_citation_parts(citation_upper, citation_lower_start, citation_lower_end = nil)
          citation_lower =
            if citation_lower_start == citation_lower_end
              citation_lower_start
            else
              [citation_lower_start, citation_lower_end].compact.join('-')
            end

          [citation_upper, citation_lower].compact.join(' ')
        end

        def process_div_for_sentences(citation_upper, div, pattern, options)
          div.sentences.each do |sentence|
            s = sentence.presentation_before || ''
            citation_lower_start = nil
            citation_lower_end = nil

            sentence.tokens.each do |token|
              unless token.is_empty?
                s += token.presentation_before || ''
                s += token.form || ''
                s += token.presentation_after || ''

                citation_lower_start = token.citation_part if citation_lower_start.nil?
                citation_lower_end = token.citation_part
              end
            end

            s += sentence.presentation_after || ''

            citation = merge_citation_parts(citation_upper, citation_lower_start, citation_lower_end)
            match(s, citation, sentence.id, pattern, options)
          end
        end

        def process_div_for_tokens(citation_upper, div, pattern, options)
          div.sentences.each do |sentence|
            sentence.tokens.each do |token|
              unless token.is_empty?
                s = token.presentation_before || ''
                s += token.form || ''
                s += token.presentation_after || ''

                citation = merge_citation_parts(citation_upper, token.citation_part)
                match(s, citation, token.id, pattern, options)
              end
            end
          end
        end

        def process_div(citation_upper, div, pattern, options)
          case options['level']
          when 'sentence'
            process_div_for_sentences(citation_upper, div, pattern, options)
          when 'token'
            process_div_for_tokens(citation_upper, div, pattern, options)
          end
        end

        def process(args, options)
          if args.empty?
            STDERR.puts 'Missing pattern. Use --help for more information.'
            exit 1
          end

          pattern_string = args.shift

          pattern =
            if options['ignore-case']
              Regexp.new(pattern_string, Regexp::IGNORECASE)
            else
              Regexp.new(pattern_string)
            end

          if args.empty?
            STDERR.puts 'Missing filename(s). Use --help for more information.'
            exit 1
          end

          options['level'] ||= 'sentence'

          unless %w(token sentence).include?(options['level'])
            STDERR.puts 'Invalid matching level. Use --help for more information.'
            exit 1
          end

          tb = PROIEL::Treebank.new

          args.each do |filename|
            STDERR.puts "Reading #{filename}...".green if options['verbose']

            tb.load_from_xml(filename)
          end

          tb.sources.each do |source|
            citation_upper = source.citation_part

            source.divs.each do |div|
              process_div(citation_upper, div, pattern, options)
            end
          end
        end
      end
    end
  end
end
