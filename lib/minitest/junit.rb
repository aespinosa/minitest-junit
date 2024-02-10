require 'minitest/junit/version'
require 'minitest'
require 'builder'
require 'socket'
require 'time'

# :nodoc:
module Minitest
  module Junit
    # :nodoc:
    class Reporter
      def initialize(io, options)
        @io = io
        @results = []
        @options = options
        @options[:timestamp] = options.fetch(:timestamp, Time.now.iso8601)
        @options[:hostname] = options.fetch(:hostname, Socket.gethostname)
      end

      def passed?
        true
      end

      def start; end

      def record(result)
        @results << result
      end

      def report
        xml = Builder::XmlMarkup.new(:indent => 2)
        xml.testsuite(name: 'minitest',
                      timestamp: @options[:timestamp],
                      hostname: @options[:hostname],
                      tests: @results.count,
                      skipped: @results.count { |result| result.skipped? },
                      failures: @results.count { |result| !result.error? && result.failure },
                      errors: @results.count { |result| result.error? },
                      time: format_time(@results.inject(0) { |a, e| a += e.time })) do
                        @results.each { |result| format(result, xml) }
                      end
        @io.puts xml.target!
      end

      def format(result, parent = nil)
        xml = Builder::XmlMarkup.new(:target => parent, :indent => 2)
        xml.testcase classname: format_class(result),
                     name: format_name(result),
                     time: format_time(result.time),
                     file: result.source_location.first,
                     line: result.source_location.last,
                     assertions: result.assertions do |t|
          if result.skipped?
            t.skipped message: result
          else
            result.failures.each do |failure|
              type = classify failure
              xml.tag! type, format_backtrace(failure), message: result
            end
          end
        end
        xml
      end

      private

      def classify(failure)
        if failure.instance_of? UnexpectedError
          'error'
        else
          'failure'
        end
      end

      def format_backtrace(failure)
        failure.backtrace.join("\n")
      end

      def format_class(result)
        if @options[:junit_jenkins]
          result.klass.to_s.gsub(/(.*)::(.*)/, '\1.\2')
        else
          result.klass
        end
      end

      def format_name(result)
        result.name
      end

      def format_time(time)
        Kernel::format('%.6f', time)
      end
    end
  end
end
