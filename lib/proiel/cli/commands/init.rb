module PROIEL
  module Commands
    class Init < Command
      class << self
        def init_with_program(prog)
          prog.command(:init) do |c|
            c.syntax 'init name'
            c.description 'Initialize a new project'

            c.action do |args, options|
              if args.empty?
                STDERR.puts 'Missing project name. Use --help for more information.'
              elsif args.length > 1
                STDERR.puts 'Invalid project name. Use --help for more information.'
              else
                process(args, options)
              end
            end
          end
        end

        def process(args, options)
          project_name = args.first

          Dir.mkdir(project_name)
          Dir.mkdir(File.join(project_name, 'vendor'))

          File.open(File.join(project_name, 'Gemfile'), 'w') do |f|
            f.puts "source 'https://rubygems.org'"
            f.puts
            f.puts "gem 'proiel'"
          end

          File.open(File.join(project_name, 'myproject.rb'), 'w') do |f|
            f.puts "#!/usr/bin/env ruby"
            f.puts "require 'proiel'"
            f.puts
            f.puts "tb = PROIEL::Treebank.new"
            f.puts "Dir[File.join('vendor', 'proiel-treebank', '*.xml')].each do |filename|"
            f.puts '  puts "Reading #{filename}..."'
            f.puts "  tb.load_from_xml(filename)"
            f.puts "end"
            f.puts

            f.puts "tb.sources.each do |source|"
            f.puts "  source.divs.each do |div|"
            f.puts "    div.sentences.each do |sentence|"
            f.puts "      sentence.tokens.each do |token|"
            f.puts "        # Do something"
            f.puts "      end"
            f.puts "    end"
            f.puts "  end"
            f.puts "end"
          end

          Dir.chdir(project_name) do
            `git init`
#            `git submodule add --depth 1 https://github.com/proiel/proiel-treebank.git vendor/proiel-treebank`
#            `bundle`
          end
        end
      end
    end
  end
end

