# Minitest::Junit

Generates a JUnit-compatible XML report for consumption with Jenkins.

## Installation

Add this line to your application's Gemfile:

    gem 'minitest-junit'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install minitest-junit

## Usage

    $ ruby your_test.rb --help
    minitest options:
    ...
    Known extensions: junit, ...
            --junit                      Generate a junit xml report
            --junit-filename=OUT         Target output filename. Defaults to report.xml
            --junit-jenkins              Sanitize test names for Jenkins display
    ...

## Contributing

1. Fork it ( https://github.com/aespinosa/minitest-junit/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
