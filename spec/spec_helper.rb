require 'simplecov'
SimpleCov.start do
  add_filter '/spec/'
end

ENV['RAILS_ENV'] ||= 'test'

require_relative '../lib/stretchie'

pwd = File.expand_path File.dirname(__FILE__)
Dir[File.join(pwd, 'support/**/*.rb')].each { |f| require_relative f }

RSpec.configure do |config|
  if config.files_to_run.one?
    config.default_formatter = 'doc'
  end

  config.order = :random
  Kernel.srand config.seed
end

