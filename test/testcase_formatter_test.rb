require 'minitest/autorun'
require 'stringio'
require 'time'

require 'minitest/junit'

class TestCaseFormatter < Minitest::Test
  def test_all_tests_generate_testcase_tag
    test = create_test_result
    reporter = create_reporter

    assert_match test.name, reporter.format(test)
  end

  def test_skipped_tests_generates_skipped_tag
    test = create_test_result
    test.failures << create_error(Minitest::Skip)
    reporter = create_reporter
    reporter.record test

    reporter.report

    assert_match(/<skipped message=".+"\/>.*/, reporter.output)
  end

  def test_failing_tests_creates_failure_tag
    test = create_test_result
    test.failures << create_error(Minitest::Assertion)
    reporter = create_reporter
    reporter.record test

    reporter.report

    assert_match(/<failure/, reporter.output)
  end

  def test_other_errors_generates_error_tag
    test = create_test_result
    test.failures << Minitest::UnexpectedError.new(create_error(Exception))
    reporter = create_reporter
    reporter.record test

    reporter.report

    assert_match(/<error/, reporter.output)
  end

  def test_jenkins_sanitizer_uses_modules_as_packages
    test = create_test_result 'FirstModule::SecondModule::TestClass'
    reporter = create_reporter junit_jenkins: true
    reporter.record test

    reporter.report

    assert_match 'FirstModule::SecondModule.TestClass', reporter.output
  end

  private

  def create_error(klass)
    fail klass, "A #{klass} failure"
  rescue klass => e
    e
  end

  def create_test_result(name = 'ATestClass')
    test = Class.new Minitest::Test do
      define_method 'class' do
        name
      end
    end.new 'test_method_name'
    test.time = a_number
    test.assertions = a_number
    test
  end

  def a_number
    rand(100)
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
