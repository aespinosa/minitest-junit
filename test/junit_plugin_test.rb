require 'minitest/autorun'
require 'minitest/mock'
require 'minitest/junit_plugin'

# :nodoc:
class PluginTest < Minitest::Test
  def test_by_default_the_plugin_is_disabled
    opts = OptionParser.new
    options = {}

    Minitest.plugin_junit_options opts, options
    opts.parse('')

    assert_equal({}, options)
  end

  def test_setting_the_commandline_activates_the_plugin
    opts = OptionParser.new
    options = {}
    Minitest.plugin_junit_options opts, options
    opts.parse('--junit')

    assert_equal({ junit: true }, options)
  end

  def test_by_default_doesnt_include_the_repoter
    options = {}
    Minitest.reporter = []

    Minitest.plugin_junit_init(options)

    assert_equal [], Minitest.reporter
  end

  def test_when_enabled_adds_the_plugin_to_the_list_of_reporters
    options = { junit: true }
    Minitest.reporter = []

    Minitest.plugin_junit_init(options)

    assert_instance_of Minitest::Junit::Reporter, Minitest.reporter[0]
  end

  def test_output_is_dumped_to_reportxml_by_default
    file_klass = Minitest::Mock.new
    options = { junit: true, file_klass: file_klass }
    Minitest.reporter = []

    file_klass.expect(:new, true, ['report.xml', 'w'])
    Minitest.plugin_junit_init(options)

    file_klass.verify
  end

  def test_output_is_dumped_to_specified_filename
    file_klass = Minitest::Mock.new
    options = { junit: true, junit_filename: 'somefile.xml',
                file_klass: file_klass }
    Minitest.reporter = []

    file_klass.expect(:new, true, ['somefile.xml', 'w'])
    Minitest.plugin_junit_init(options)

    file_klass.verify
  end

  def test_custom_filename_is_specified_by_a_flag
    opts = OptionParser.new
    options = {}

    Minitest.plugin_junit_options opts, options
    opts.parse('--junit-filename=somefile.xml')

    assert_equal 'somefile.xml', options[:junit_filename]
  end
end
