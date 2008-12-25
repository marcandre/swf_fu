require 'test/unit'
require File.dirname(__FILE__)+'/../../../../config/environment.rb'
require 'action_view/test_case'
require "action_controller/test_process"
require 'shoulda'

def assert_starts_with(start, what)
  assert what.starts_with?(start), "#{what} does not start with #{start}"
end