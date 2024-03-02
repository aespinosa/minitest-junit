require 'minitest/autorun'
require 'stringio'
require 'time'
require 'nokogiri'

require 'minitest/junit'

class FakeTestName; end

class ReporterTest < Minitest::Test
  def test_no_tests_generates_an_empty_suite
    reporter = create_reporter

    reporter.report

    assert_match(
      %r{<?xml version="1.0" encoding="UTF-8"\?>\n<testsuite name="minitest" timestamp="[^"]+" hostname="[^"]+" tests="0" skipped="0" failures="0" errors="0" time="0.000000"\/>},
      reporter.output
    )
  end

  def test_formats_each_successful_result_with_a_formatter
    reporter = create_reporter

    results = do_formatting_test(reporter, count: rand(100), cause_failures: 0)

    results.each do |result|
      assert_match("<testcase classname=\"FakeTestName\" name=\"#{result.name}\"", reporter.output)
    end
  end

  def test_formats_each_failed_result_with_a_formatter
    reporter = create_reporter

    results = do_formatting_test(reporter, count: rand(100), cause_failures: 1)
    parsed_report = Nokogiri::XML(reporter.output)
    results.each do |result|
      parsed_report.xpath("//testcase[@name='#{result.name}']").any?
    end
    # Check if some testcase has a failure and screenshot path
    assert parsed_report.xpath("//testcase//failure").any?
    assert parsed_report.xpath("//testcase//system-out").any?
  end

  def test_xml_nodes_has_file_and_line_attributes
    reporter = create_reporter
    results = do_formatting_test(reporter, count: 2, cause_failures: 1)
    parsed_report = Nokogiri::XML(reporter.output)
    example_node = parsed_report.xpath("//testcase").first
    assert example_node.has_attribute?('file')
    assert example_node.has_attribute?('line')
    assert_equal 'unknown', example_node.attribute('file').value
    assert_equal '-1', example_node.attribute('line').value
  end

  private

  def do_formatting_test(reporter, count: 1, cause_failures: 0)
    results = count.times.map do |i|
      result = create_test_result(methodname: "test_name#{i}", failures: cause_failures)
      reporter.record result
      result
    end

    reporter.report

    results
  end

  def create_test_result(name: FakeTestName, methodname: 'test_method_name', successes: 1, failures: 0)
    test = Class.new Minitest::Test do
      define_method 'class' do
        name
      end
    end.new methodname
    test.time = rand(100)
    test.assertions = successes + failures
    test.failures = failures.times.map do |i|
      Class.new Minitest::Assertion do
        define_method 'backtrace' do
          ["Model failure \##{i}", 'This is a test backtrace', "#{__FILE__}:#{__LINE__}"]
        end
      end.new
    end

    if failures.positive?
      test.metadata[:failure_screenshot_path] = '/tmp/screenshot.png'
    end

    Minitest::Result.from test
  end

  def create_reporter(options = {})
    io = StringIO.new ''
    reporter = Minitest::Junit::Reporter.new io, options
    def reporter.output
      @io.string
    end
    reporter.start
    reporter
  end
end
