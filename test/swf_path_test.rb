require 'test_helper'

class SwfPathTest < ActionView::TestCase
  context "with no special asset host" do
    should "deduce the extension" do
      assert_equal swf_path("example.swf"), swf_path("example")
      assert_match "/swfs/example.swf", swf_path("example.swf")
    end

    should "accept relative paths" do
      assert_equal "/swfs/whatever/example.swf", swf_path("whatever/example.swf")
    end

    should "leave full paths alone" do
      ["/full/path.swf", "http://www.example.com/whatever.swf"].each do |p|
        assert_equal p, swf_path(p)
      end
    end
  end

  context "with custom asset host" do
    HOST = "http://assets.example.com"
    setup do
      ActionController::Base.asset_host = HOST
    end

    teardown do
      ActionController::Base.asset_host = nil
    end

    should "take it into account" do
      assert_equal "#{HOST}/swfs/whatever.swf", swf_path("whatever")
    end
  end
end