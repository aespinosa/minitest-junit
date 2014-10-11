require 'minitest/autorun'
require 'stringio'
require 'time'

require 'minitest/junit'

class ReporterTest < Minitest::Test
  def test_no_tests_generates_an_empty_suite
    reporter = create_reporter

    reporter.report

    assert_equal "<testsuite>\n</testsuite>\n", reporter.output
  end

  def test_formats_each_result_with_a_formatter
    reporter = create_reporter
    results = rand(100).times.map do |i|
      result = "test_name#{i}"
      reporter.record result
      result
    end

    reporter.report

    expected = "<testsuite>\n#{results.join "\n"}\n</testsuite>\n"
    assert_equal expected, reporter.output
  end

  private

  def create_reporter
    io = StringIO.new
    reporter = Minitest::Junit::Reporter.new io
    def reporter.output
      @io.string
    end
    def reporter.format(result)
      result
    end
    reporter.start
    reporter
  end
end
