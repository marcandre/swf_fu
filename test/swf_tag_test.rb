require 'test_helper'

class SwfTagTest < ActionView::TestCase

  COMPLEX_OPTIONS = { :width => "456", :height => 123,
                      :flashvars => {:myVar => "value 1 > 2"}.freeze,
                      :javascript_class => "SomeClass",
                      :initialize => {:be => "good"}.freeze,
                      :parameters => {:play => true}.freeze
                    }.freeze

  should "understand size" do
    assert_equal  swf_tag("hello", :size => "123x456"),
                  swf_tag("hello", :width => 123, :height => "456")
  end

  should "only accept valid modes" do
    assert_raise(ArgumentError) { swf_tag("xyz", :mode => :xyz)  }
  end

  context "with custom defaults" do
    setup do
      test = {:flashvars=> {:xyz => "abc", :hello => "world"}.freeze, :mode => :static, :size => "400x300"}.freeze
      @expect = swf_tag("test", test)
      @expect_with_hello = swf_tag("test", :flashvars => {:xyz => "abc", :hello => "my friend"}, :mode => :static, :size => "400x300")
      ActionView::Base.swf_default_options = test
    end

    should "respect them" do
      assert_equal @expect, swf_tag("test")
    end

    should "merge suboptions" do
      assert_equal @expect_with_hello, swf_tag("test", :flashvars => {:hello => "my friend"}.freeze)
    end

    teardown { ActionView::Base.swf_default_options = {} }
  end

  context "with proc options" do
    should "call them" do
      expect = swf_tag("test", :id => "generated_id_for_test")
      assert_equal expect, swf_tag("test", :id => Proc.new{|arg| "generated_id_for_#{arg}"})
    end

    should "call global default's everytime" do
      expect1 = swf_tag("test", :id => "call_number_1")
      expect2 = swf_tag("test", :id => "call_number_2")
      cnt = 0
      ActionView::Base.swf_default_options = { :id => Proc.new{ "call_number_#{cnt+=1}" }}
      assert_equal expect1, swf_tag("test")
      assert_equal expect2, swf_tag("test")
    end
  end

  context "with static mode" do
    setup { ActionView::Base.swf_default_options = {:mode => :static} }

    should "deal with string flashvars" do
      assert_equal  swf_tag("hello", :flashvars => "xyz=abc", :mode => :static),
                    swf_tag("hello", :flashvars => {:xyz => "abc"}, :mode => :static)
    end

    should "produce the expected code" do
      assert_same_stripped STATIC_RESULT, swf_tag("mySwf", COMPLEX_OPTIONS.merge(:html_options => {:class => "lots"}.freeze).freeze),
        [%q[value="id=mySwf&myVar=value+1+%3E+2"], %q[value="myVar=value+1+%3E+2&id=mySwf"]]
    end

    teardown { ActionView::Base.swf_default_options = {} }
  end

  context "with dynamic mode" do
    should "produce the expected code" do
      assert_same_stripped DYNAMIC_RESULT, swf_tag("mySwf", COMPLEX_OPTIONS),
        [%q[{"id":"mySwf","myVar":"value 1 \u003E 2"}], %q[{"myVar":"value 1 \u003E 2","id":"mySwf"}]]
    end

  end

  should "enforce HTML id validity" do
    div_result = '<div id="swf_123-456_ok___X_div">'
    assert_match /#{div_result}/, swf_tag("123-456_ok$!+X")
    obj_result = '"id":"swf_123-456_ok___X"'
    assert_match /#{obj_result}/, swf_tag("123-456_ok$!+X")
  end

  should "treat initialize arrays as list of parameters" do
    assert_match '"hello","world"])', swf_tag("mySwf", :initialize => ["hello", "world"], :javascript_class => "SomeClass")
  end

  should "be html safe" do
    assert swf_tag("test").html_safe?
  end
end

