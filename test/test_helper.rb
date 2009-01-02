require 'test/unit'
require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_view'

#require File.dirname(__FILE__)+'/../../../../config/environment.rb'
require 'action_view/test_case'
require "action_controller/test_process"
require 'shoulda'
require File.dirname(__FILE__) + '/../init'

def assert_starts_with(start, what)
  assert what.starts_with?(start), "#{what} does not start with #{start}"
end