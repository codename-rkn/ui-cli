#!/usr/bin/env ruby
=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the RKN::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the RKN::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'rkn/ui/cli'
require 'rkn/ui/cli/system_info'

RKN::UI::CLI::SystemInfo.new.run
