require 'builder'
require 'colorize'
require 'mercenary'
require 'proiel'
require 'pry'
require 'ruby-progressbar'

require 'proiel/cli/version'

module PROIEL
  class Command
    class << self
      def subclasses
        @subclasses ||= []
      end

      def inherited(base)
        subclasses << base
        super(base)
      end
    end
  end

  module Converter; end
end

Dir[File.join(File.dirname(__FILE__), 'cli', '{commands,converters}', '*.rb')].each do |f|
  require f
end