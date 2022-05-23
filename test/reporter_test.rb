require 'minitest/autorun'
require 'builder'
require 'stringio'
require 'time'

require 'minitest/junit'

class ReporterTest < Minitest::Test
  def test_no_tests_generates_an_empty_suite
    reporter = create_reporter

    reporter.report

    assert_match(/^<testsuite name="minitest" timestamp="[^"]+" hostname="[^"]+" tests="0" skipped="0" failures="0" errors="0" time="0.000000">\n<\/testsuite>\n$/, reporter.output)
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

    results.each do |result|
      assert_match("<testcase classname=\"FakeTestName\" name=\"#{result.name}\"", reporter.output)
      assert_match(/<failure/, reporter.output)
    end
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
          ["Model failure \##{i}", 'This is a test backtrace']
        end
      end.new
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
