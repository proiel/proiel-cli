module PROIEL
  module Commands
    class Dictionary < Command
      class << self
        def init_with_program(prog)
          prog.command(:dictionary) do |c|
            c.syntax 'dictionary [options] filename(s)'
            c.description 'Build a dictionary'

            c.option 'glosses', '--merge-glosses glosses.tsv', 'Merge glosses from an external file'
            c.option 'gloss-languages', '--merge-gloss-languages eng,rus', 'Merge glosses from selected languages'

            c.action { |args, options| process(args, options) }
          end
        end

        def process(args, options)
          tb = PROIEL::Treebank.new
          dict = PROIEL::DictionaryBuilder.new

          args.each do |filename|
            STDERR.puts "Reading #{filename}...".green if options['verbose']

            tb.load_from_xml(filename)
          end

          if options['glosses']
            languages = (options['gloss-languages'] || 'eng').split(',').map(&:to_sym)
            if File.exists?(options['glosses'])
              dict.add_external_glosses!(options['glosses'], languages)
            else
              STDERR.puts "#{options['glosses']} not found"
              exit 1
            end
          end

          tb.sources.each do |source|
            dict.add_source!(source)
          end

          dict.to_xml(STDOUT)
        end
      end
    end
  end
end
