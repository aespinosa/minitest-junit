require 'minitest/junit/version'
require 'minitest'
require 'builder'

# :nodoc:
module Minitest
  module Junit
    # :nodoc:
    class Reporter
      def initialize(io)
        @io = io
        @results = []
      end

      def passed?; end

      def start; end

      def record(result)
        @results << result
      end

      def report
        @io.puts '<testsuite>'
        @results.each { |result| @io.puts format(result) }
        @io.puts '</testsuite>'
      end

      def format(result)
        xml = Builder::XmlMarkup.new
        xml.testcase classname: format_class(result), name: format_name(result),
                     time: result.time, assertions: result.assertions do |t|
          t.skipped if result.skipped?
          result.failures.each do |failure|
            type = classify failure
            xml.tag! type, format_backtrace(failure), message: result
          end
        end
        xml.target!
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
        result.class
      end

      def format_name(result)
        result.name
      end
    end
  end
end
