=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the RKN::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the RKN::UI::CLI
    web site for more information on licensing and terms of use.
=end

module RKN

require 'rkn/ui/cli/mixins/terminal'

module UI::CLI

module Utilities
    include SCNR::Engine::Utilities
    include Mixins::Terminal

    def print_entries( entries, unmute = false, &interceptor )
        entries = entries.sort_by { |e| e[:mutation][:affected_input_name] }

        interceptor ||= proc { |s| s }

        print_line( interceptor.call, unmute )
        print_info( interceptor.call( "#{entries.size} entries have been identified." ), unmute )

        print_line( interceptor.call, unmute )

        entry_cnt = entries.size
        entries.each.with_index do |entry, i|
            input = "input `#{entry[:mutation][:affected_input_name]}`"
            meth  = "using #{entry[:mutation][:method].to_s.upcase}"

            cnt = "#{i + 1} |".rjust( entry_cnt.to_s.size + 2 )

            print_ok( interceptor.call(  "#{cnt} #{entry[:mutation][:type].capitalize} #{input} #{meth} is #{entry[:sink]} - #{entry[:mutation][:action]}" ),
                      unmute
            )
        end

        print_line( interceptor.call, unmute )
    end

    # Loads an Engine Framework Profile file and merges it with the user
    # supplied options.
    #
    # @param    [String]    profile
    def load_profile( profile )
        exception_jail do
            Engine::Options.load( profile )
        end
    end

    # Saves options to an Engine Framework Profile file.
    #
    # @param    [String]    filename
    def save_profile( filename )
        if (filename = Engine::Options.save( filename ))
            print_status "Saved profile in '#{filename}'."
            print_line
        else
            banner
            print_error 'Could not save profile.'
            exit 0
        end
    end

    # Outputs Engine banner.
    # Displays version number, author details etc.
    #
    # @see VERSION
    def print_banner
        puts BANNER
        puts
        puts
    end

end
end
end
