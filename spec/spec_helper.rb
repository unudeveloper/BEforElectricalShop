require 'simplecov'

# @todo: Always run simplecov again once
# https://github.com/colszowka/simplecov/issues/404,
# https://github.com/glebm/i18n-tasks/issues/221 are fixed
if ENV['COVERAGE'] == 'true'
  SimpleCov.start do
    add_filter 'spec/'
    add_filter 'features/'
  end
end

if ENV['CI'] == 'true'
  require 'codecov'
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end
