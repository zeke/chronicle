require 'rubygems'
require 'bundler/setup'

require 'chronicle'
include Chronicle

require 'active_support/all' # to get methods like blank? and starts_with?

# include ActionView::Helpers
include ActiveSupport

RSpec.configure do |config|
  # some (optional) config here
end