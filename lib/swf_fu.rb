require File.dirname(__FILE__) + "/action_view/helpers/swf_fu_helper"
require File.dirname(__FILE__) + "/action_view/helpers/asset_tag_helper"

ActionView::Helpers::AssetTagHelper.class_eval do
  include ActionView::Helpers::SwfFuHelper
end


ActionView::Helpers::AssetTagHelper.register_javascript_include_default 'swfobject'

module SwfFu ; end