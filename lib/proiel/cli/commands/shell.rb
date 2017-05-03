module PROIEL
  module Commands
    class Shell < Command
      class << self
        def init_with_program(prog)
          prog.command(:shell) do |c|
            c.syntax 'shell filename(s)'
            c.description 'Launch a shell with the treebank loaded'

            c.action do |args, options|
              if args.empty?
                STDERR.puts 'Missing filename(s). Use --help for more information.'
              else
                process(args, options)
              end
            end
          end
        end

        def process(args, options)
          tb = PROIEL::Treebank.new

          args.each do |filename|
            STDERR.puts "Reading #{filename}...".green if options['verbose']

            tb.load_from_xml(filename)
          end

          binding.pry
        end
      end
    end
  end
end
