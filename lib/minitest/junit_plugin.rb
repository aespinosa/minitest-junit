require 'minitest/junit'

# :nodoc:
module Minitest
  def self.plugin_junit_options(opts, options)
    opts.on '--junit', 'Generate a junit xml report' do
      options[:junit] = true
    end
    opts.on '--junit-filename=OUT', 'Target output filename.'\
                                    ' Defaults to report.xml' do |out|
      options[:junit_filename] = out
    end
    opts.on '--junit-jenkins', 'Sanitize test names for Jenkins display' do
      options[:junit_jenkins] = true
    end
  end

  def self.plugin_junit_init(options)
    return unless options.delete :junit
    file_klass = options.delete(:file_klass) || File
    io = file_klass.new options.delete(:junit_filename) || 'report.xml', 'w'
    reporter << Junit::Reporter.new(io, options)
  end
end
