module PROIEL
  module Commands
    class Validate < Command
      class << self
        def init_with_program(prog)
          prog.command(:validate) do |c|
            c.syntax 'validate'
            c.description 'Validate input data'
            c.action { |args, options| process(args, options) }
          end
        end

        def process(args, options)
          if args.empty?
            STDERR.puts 'Missing filename(s). Use --help for more information.'
            exit 1
          end

          @schemas = {}

          args.each do |filename|
            v = PROIEL::PROIELXML::Validator.new(filename)

            if v.valid?
              puts "#{filename} is valid".green

              exit 0
            else
              puts "#{filename} is invalid".red

              v.errors.each do |error|
                puts "* #{error}"
              end

              exit 1
            end
          end
        end
      end
    end
  end
end
