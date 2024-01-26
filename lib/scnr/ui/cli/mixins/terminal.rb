=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'io/console'

module SCNR
module UI::CLI
module Mixins

# Terminal manipulation methods.
module Terminal

    # Clears the line before printing using `puts`.
    #
    # @param    [String]    str
    #   String to output
    def reputs( str = '' )
        reprint str + "\n"
    end

    # Clears the line before printing.
    #
    # @param    [String]    str
    #   String to output.
    def reprint( str = '' )
        print restr( str )
    end

    def restr( str = '' )
        "\e[0K" + str
    end

    # Clear the bottom of the screen
    def clear_screen
        print "\e[2J"
    end

    def empty_screen
        move_to_home
        rows, cols = $stdin.winsize
        (rows - 1).times{ puts ' ' * cols }
        move_to_home
    end

    # Moves cursor top left to its home
    def move_to_home
        print "\e[H"
    end

    # Flushes the STDOUT buffer
    def flush
        $stdout.flush
    end

    extend self
end

end
end
end
