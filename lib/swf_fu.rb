require File.dirname(__FILE__) + "/action_view/helpers/swf_fu_helper"
require File.dirname(__FILE__) + "/action_view/helpers/asset_tag_helper"

# ActionView::Helpers is for recent rails version, ActionView::Base for older ones (in which case ActionView::Helpers::AssetTagHelper is also needed for tests...)
[ActionView::Helpers::AssetTagHelper, ActionView::Base, ActionView::Helpers].each {|mod| mod.class_eval do
  include ActionView::Helpers::SwfFuHelper
end}


ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'swfobject'

module SwfFu ; end