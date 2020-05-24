module PROIEL
  module Commands
    class Build < Command
      class << self
        def init_with_program(prog)
          prog.command(:build) do |c|
            c.syntax 'build resource'
            c.description 'Build a derived resource'

            c.command(:dictionary) do |f|
              f.syntax 'output_filename [filename(s)]'
              f.description 'Build a dictionary from treebank data'
              f.action { |args, options| process_dictionary(args, options) }
            end

            c.command(:dictionaries) do |f|
              f.syntax '[filename(s)]'
              f.description 'Build multiple dictionaries (one per language) from treebank data'
              f.action { |args, options| process_dictionaries(args, options) }
            end

            c.action do |_, _|
              STDERR.puts 'Missing or invalid format. Use --help for more information.'
              exit 1
            end
          end
        end

        def process_dictionary(args, options)
          if args.empty?
            STDERR.puts 'Missing output filename. Use --help for more information.'
            exit 1
          end

          output_filename, *input_filenames = args
          dicts = {}

          tb = PROIEL::Treebank.new
          dict = PROIEL::Dictionary::Builder.new

          if input_filenames.empty?
            STDERR.puts 'Reading from standard input...'.green if options['verbose']

            tb.load_from_xml(STDIN)
            tb.sources.each { |source| dict.add_source!(source) }
          else
            input_filenames.each do |filename|
              STDERR.puts "Reading #{filename}...".green if options['verbose']

              tb.load_from_xml(filename)
            end
          end

          tb.sources.each { |source| dict.add_source!(source) }

          File.open(output_filename, 'w') do |f|
            dict.to_xml(f)
          end
        end

        def process_dictionaries(args, options)
          dicts = {}

          if args.empty?
            STDERR.puts 'Reading from standard input...'.green if options['verbose']

            tb = PROIEL::Treebank.new
            tb.load_from_xml(STDIN)
            tb.sources.each do |source|
              dicts[source.language] ||= PROIEL::Dictionary::Builder.new
              dicts[source.language].add_source!(source)
            end
          else
            tb = PROIEL::Treebank.new

            args.each do |filename|
              STDERR.puts "Reading #{filename}...".green if options['verbose']
              tb.load_from_xml(filename)
            end

            tb.sources.each do |source|
              dicts[source.language] ||= PROIEL::Dictionary::Builder.new
              dicts[source.language].add_source!(source)
            end
          end

          dicts.each do |language, dict|
            File.open("#{language}.xml", 'w') do |f|
              dict.to_xml(f)
            end
          end 
        end
      end
    end
  end
end