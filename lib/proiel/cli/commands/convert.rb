module PROIEL
  module Commands
    class Convert < Command
      class << self
        def init_with_program(prog)
          prog.command(:convert) do |c|
            c.syntax 'convert format'
            c.description 'Convert to a different format'

            c.command(:proielxml) do |f|
              f.syntax '[options] [filename(s)]'
              f.description 'Convert to PROIEL XML format'
              f.option 'remove-not-annotated', '--remove-not-annotated', 'Remove sentences that have not been annotated'
              f.option 'remove-not-reviewed', '--remove-not-reviewed', 'Remove sentences that have not been reviewed'
              f.option 'remove-annotated', '--remove-annotated', 'Remove sentences that have been annotated'
              f.option 'remove-reviewed', '--remove-reviewed', 'Remove sentences that have been reviewed'
              f.option 'remove-morphology', '--remove-morphology', 'Remove morphological annotation (part of speech, morphology and lemma)'
              f.option 'remove-syntax', '--remove-syntax', 'Remove syntactic annotation (relation, head ID and slashes)'
              f.option 'remove-information-structure', '--remove-information-structure', 'Remove informtion structure annotation (antecedent ID, information status and contrast group)'
              f.option 'remove-status', '--remove-status', 'Remove sentence status (i.e. revert all sentences to unannotated status)'
              f.option 'remove-alignments', '--remove-alignments', 'Remove alignments'
              f.option 'remove-annotator', '--remove-annotator', 'Remove annotator information'
              f.option 'remove-reviewer', '--remove-reviewer', 'Remove reviewer information'
              f.option 'remove-empty-divs', '--remove-empty-divs', 'Remove div elements that do not contain any sentences'
              f.option 'infer-alignments', '--infer-alignments', 'Add inferred alignments when possible'
              f.option 'remove-unaligned-sources', '--remove-unaligned-sources', 'Remove sources that are not aligned'
              f.action { |args, options| process(args, options, PROIEL::Converter::PROIELXML) }
            end

            c.command(:tnt) do |f|
              f.syntax '[options] filename(s)'
              f.description 'Convert to TNT/hunpos format'
              f.option 'morphology', '-m', '--morphology', 'Include POS and morphological tags'
              f.option 'pos', '-p', '--pos', 'Include POS tags'
              f.action { |args, options| process(args, options, PROIEL::Converter::TNT) }
            end

            c.command(:"conll-x") do |f|
              f.syntax 'filename(s)'
              f.description 'Convert to CoNLL-X format'
              f.action { |args, options| process(args, options, PROIEL::Converter::CoNLLX) }
            end

            c.command(:"conll-u") do |f|
              f.syntax 'filename(s)'
              f.description 'Convert to CoNLL-U format'
              f.action { |args, options| process(args, options, PROIEL::Converter::CoNLLU) }
            end

            c.command(:tiger) do |f|
              f.syntax 'filename(s)'
              f.description 'Convert to TIGER XML format'
              f.action { |args, options| process(args, options, PROIEL::Converter::Tiger) }
            end

            c.command(:tiger2) do |f|
              f.syntax 'filename(s)'
              f.description 'Convert to TIGER2 format'
              f.action { |args, options| process(args, options, PROIEL::Converter::Tiger2) }
            end

            c.command(:text) do |f|
              f.syntax 'filename(s)'
              f.description 'Convert to plain text (UTF-8 with Unix line-endings)'
              f.option 'diffable', '-d', '--diffable', 'Make the output diffable'
              f.action { |args, options| process(args, options, PROIEL::Converter::Text) }
            end

            c.command(:lexc) do |f|
              f.syntax '[options] filename(s)'
              f.description 'Convert to lexc format'
              f.option 'morphology', '-m', '--morphology', 'Include morphological tags'
              f.action { |args, options| process(args, options, PROIEL::Converter::Lexc) }
            end

            c.action do |_, _|
              STDERR.puts 'Missing or invalid format. Use --help for more information.'
              exit 1
            end
          end
        end

        def process(args, options, converter)
          tb = PROIEL::Treebank.new

          if args.empty?
            STDERR.puts 'Reading from standard input...'.green if options['verbose']
            tb.load_from_xml(STDIN)
          else
            args.each do |filename|
              STDERR.puts "Reading #{filename}...".green if options['verbose']

              tb.load_from_xml(filename)
            end
          end

          converter.process(tb, options)
        end
      end
    end
  end
end
