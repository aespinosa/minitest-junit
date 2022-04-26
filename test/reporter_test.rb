require 'minitest/autorun'
require 'builder'
require 'stringio'
require 'time'

require 'minitest/junit'

class ReporterTest < Minitest::Test
  class MockResult
    attr_accessor :name, :failures, :time
    def initialize(name, error=false, skipped=false, failures=[], time=60)
      @name = name
      @skipped = skipped
      @error = error
      @failures = failures
      @time = time
    end

    def error?
      @error
    end

    def failure
      @failures.first
    end

    def skipped?
      @skipped
    end
  end

  def test_no_tests_generates_an_empty_suite
    reporter = create_reporter

    reporter.report

    assert_match /^<testsuite name="minitest" timestamp="[^"]+" hostname="[^"]+" tests="0" skipped="0" failures="0" errors="0" time="0.000000">\n<\/testsuite>\n$/, reporter.output
  end

  def test_formats_each_result_with_a_formatter
    reporter = create_reporter
    results = rand(100).times.map do |i|
      result = MockResult.new "test_name#{i}"
      reporter.record result
      result
    end

    reporter.report

    results.each do |result|
      assert_match "<testcase name=\"#{result.name}\"\/>", reporter.output
    end
  end

  private

  def create_reporter
    io = StringIO.new
    reporter = Minitest::Junit::Reporter.new io, {}
    def reporter.output
      @io.string
    end
    def reporter.format(result, parent=nil)
      xml = Builder::XmlMarkup.new(:target=>parent)
      xml.testcase name: result.name
      result
    end
    reporter.start
    reporter
  end
end
