=begin
    Copyright 2024 Ecsypno Single Member P.C.

    This file is part of the SCNR::UI::CLI project and is subject to
    redistribution and commercial restrictions. Please see the SCNR::UI::CLI
    web site for more information on licensing and terms of use.
=end

require 'scnr/engine'
require_relative 'reproduce/option_parser'
require_relative 'utilities'

module SCNR
module UI::CLI

# @author Tasos "Zapotek" Laskos <tasos.laskos@gmail.com>
class Reproduce
    include Output
    include Utilities

    COLUMNS = 120

    def initialize
        SCNR::License.guard! :dev, :trial, :basic, :pro, :sdlc, :enterprise

        run
    end

    def with_browser( &block )
        @browser_cluster ||= Engine::BrowserCluster.new
        @browser_cluster.with_browser( &block )
    end

    private

    def run
        parser = OptionParser.new
        parser.report_options
        parser.parse

        report = parser.report
        issues  = parser.issues.any? ? parser.issues : report.issues

        updated_report_path = SCNR::Engine::Options.report.path

        # Make sure we restore the options for the previous scan.
        Engine::Options.update report.options

        @start_datetime = Time.now

        reproduced_issues = []
        missing_issues    = []
        issues.each.with_index do |stale_issue, i|
            print_issue_heading( issues.size, i + 1, stale_issue )
            print_line

            h2 'Reproducing', :status
            print_line
            if (issue = stale_issue.recheck)
                reproduced_issues << issue
                replay_issue( issue )
            else
                missing_issues << stale_issue
                print_bad 'Could not reproduce, may have been fixed.'
            end

            print_line
        end

        @finish_datetime = Time.now

        h1 "Reproduced #{reproduced_issues.size} issues", :ok
        if reproduced_issues.any?
            print_info 'These issues were successfully replayed.'
        else
            print_info 'No issues were successfully replayed.'
        end

        print_line
        reproduced_issues.each do |issue|
            print_issue( issue )
            print_line
        end
        print_line

        h1 "Missing #{missing_issues.size} issues", :bad
        if missing_issues.any?
            print_info 'These issues could not be replayed, they may have been ' <<
                           'fixed or require a workflow that can only be triggered by a full scan.'
        else
            print_info 'All issues were successfully replayed.'
        end

        print_line
        missing_issues.each do |issue|
            print_issue( issue )
            print_line
        end
        print_line

        h1 'Updated report'
        filepath = store_updated_report( updated_report_path, reproduced_issues )
        print_info 'Report with reproduced issues saved at:'
        print_info "    #{filepath}"
        print_line
        h1 'Scan seed'
        print_info 'You can use this to identify tainted inputs (params, ' <<
                       'cookies, etc.) and sinks (response bodies, SQL queries etc.).'
        print_info "It is accessible via the '#{Engine::HTTP::Client::SEED_HEADER_NAME}' header."
        print_line
        print_info Engine::Utilities.random_seed
        print_line
    end

    def store_updated_report( location, issues )
        Engine::Report.new( issues: issues ).save( location )
    end

    def replay_issue( issue )
        is_dom_vector = issue.vector.is_a?( Engine::Element::DOM )

        print_line

        if issue.active?
            response = nil

            Engine::HTTP::Client.sandbox do
                # Let's provide some server side debug info for code instrumentation
                # and the like.
                Engine::HTTP::Client.headers.merge!(
                    'X-SCNR::Engine-Issue-Replay-Id' => Engine::Utilities.generate_token,
                    'X-SCNR::Engine-Issue-Seed'      => issue.vector.seed,
                    'X-SCNR::Engine-Issue-Digest'    => issue.digest
                )

                if is_dom_vector
                    issue.vector.auditor = self
                    issue.vector.submit( mode: :sync ) {}
                else
                    response = issue.vector.submit( mode: :sync )
                end
            end

            print_line
            h2 'Issue seed'
            print_info 'You can use this to identify a narrow scope of tainted ' <<
                'inputs (params, cookies, etc.) and sinks (response bodies, SQL '
            print_info 'queries etc.) related to this issue.'
            print_info "It is accessible via the 'X-SCNR::Engine-Issue-Seed' header."
            print_line
            print_line issue.vector.seed
            print_line
        else
            response = issue.response
        end

        if !issue.proof.to_s.empty?
            h2 'Proof'
            print_line
            print_line issue.proof
            print_line
        end

        return if is_dom_vector

        h2 'Request'
        print_line
        print_line response.request.to_s
        print_line
        h2 'Response'
        print_line
        print_line response.headers_string
    end

    def print_issue_heading( total, index, issue )
        h1 "(#{index}/#{total}) [#{issue.digest}] #{issue.name} in " <<
               "#{issue.vector.type}#{(' input '  +
                   issue.affected_input_name.inspect) if issue.affected_input_name}"

        h1 "From: #{issue.referring_page.dom.url}"
        h1 "At: #{issue.page.dom.url}"

        if issue.active?
            h1 "Using: #{issue.affected_input_value}"
        end

        print_line
    end

    def print_issue( issue )
        s = ''
        s << "[#{issue.digest}] #{issue.name} in #{issue.vector.type} "

        if issue.affected_input_name
            s << "input '#{issue.affected_input_name}' "
        end

        print_ok s

        print_info  "  From:  #{issue.referring_page.dom.url}"
        print_info"  At:    #{issue.page.dom.url}"

        if issue.active?
            print_info "  Using: #{issue.affected_input_value} "
        end
    end

    def h( string, character, type = :info )
        if (sz = string.size) >= COLUMNS
            marks = 0
        else
            marks = (( COLUMNS - sz) / 2.0).floor
        end

        send "print_#{type}", "#{character * marks} #{string} #{character * marks}"
    end

    def h1( string, type = :info )
        h string, '=', type
    end

    def h2( string, type = :info )
        h string, '-', type
    end

    def h3( string, type = :info )
        h string, '.', type
    end

end
end
end
