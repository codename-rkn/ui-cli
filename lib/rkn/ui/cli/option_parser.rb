=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the RKN::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the RKN::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'optparse'
require_relative 'utilities'

module RKN
module UI::CLI

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class OptionParser
    include Output
    include Utilities

    def initialize
        separator ''
        separator 'Generic'

        on( '-h', '--help', 'Output this message.' ) do
            puts parser
            exit
        end

        on( '--version', 'Show version information.' ) do
            puts "RKN::UI::CLI #{UI::CLI::VERSION}"
            puts "SCNR::Engine  #{SCNR::Engine::VERSION}"
            puts "Ruby          #{RUBY_VERSION} p#{RUBY_PATCHLEVEL} [#{RUBY_PLATFORM}]"
            exit
        end
    end

    def separator( *args )
        parser.separator( *args )
    end

    def on( *args, &block )
        parser.on( *args ) do |*bargs|
            begin
                block.call *bargs
            rescue => e
                ap e
                print_bad "#{args.first.split( /\s/ ).first}: [#{e.class}] #{e}"
                exit 1
            end
        end
    end

    def banner
        "Usage: bin/#{File.basename( $0 ).split( '.' , 2 ).first} [options]"
    end

    def parser
        @parser ||= ::OptionParser.new( banner, 27, '  ' )
    end

    def parse
        print_banner

        # Make the formatting a bit clearer with indentation for subsequent
        # description lines and empty lines between options.
        parser.top.each_option do |option|
            next if option.is_a? String
            option.desc.replace ([option.desc.shift] + option.desc.map { |l| "  #{l}" })
            option.desc << ' '
        end

        parser.parse!

        after_parse
        validate
    end

    # @abstract
    def after_parse
    end

    # @abstract
    def validate
    end

    def options
        SCNR::Engine::Options.instance
    end

    private

    def prepare_component_options( hash, argument )
        component_name, options_string = argument.split( ':', 2 )

        hash[component_name] = { }

        return hash if !options_string

        options_string.split( ',', ).each do |option|
            name, val = option.split( '=', 2 )
            hash[component_name][name] = val
        end

        hash
    end

    def paths_from_file( file )
        IO.read( file ).lines.map { |p| p.strip }
    end

end
end
end
