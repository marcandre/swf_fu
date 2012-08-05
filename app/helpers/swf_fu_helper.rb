module SwfFuHelper
  # Returns a set of tags that display a Flash object within an
  # HTML page.
  #
  # Options:
  # * <tt>:id</tt> - the DOM +id+ of the flash +object+ element that is used to contain the Flash object; defaults to the name of the swf in +source+
  # * <tt>:width, :height</tt> - the width & height of the Flash object. Defaults to "100%". These could also specified using :size
  # * <tt>:size</tt> - the size of the Flash object, in the form "400x300".
  # * <tt>:mode</tt> - Either :dynamic (default) or :static. Refer to SWFObject's doc[http://code.google.com/p/swfobject/wiki/documentation#Should_I_use_the_static_or_dynamic_publishing_method?]
  # * <tt>:flashvars</tt> - a Hash of variables that are passed to the swf. Can also be a string like <tt>"foo=bar&hello=world"</tt>
  # * <tt>:parameters</tt> - a Hash of configuration parameters for the swf. See Adobe's doc[http://kb.adobe.com/selfservice/viewContent.do?externalId=tn_12701#optional]
  # * <tt>:alt</tt> - HTML text that is displayed when the Flash player is not available. Defaults to a "Get Flash" image pointing to Adobe Flash's installation page.
  # * <tt>:flash_version</tt> - the version of the Flash player that is required (e.g. "7" (default) or "8.1.0")
  # * <tt>:auto_install</tt> - a swf file that will upgrade flash player if needed (defaults to "expressInstall" which was installed by swf_fu)
  # * <tt>:javascript_class</tt> - specify a javascript class (e.g. "MyFlash") for your flash object. The initialize method will be called when the flash object is ready.
  # * <tt>:initialize</tt> - arguments to pass to the initialization method of your javascript class.
  # * <tt>:div_id</tt> - the DOM +id+ of the containing div itself. Defaults to <tt>"#{option[:id]}"_div</tt>
  #
  def swf_tag(source, options={}, &block)
    ::SwfFu::Generator.new(source, options, self).generate(&block)
  end


  # Computes the path to an swf asset in the public 'swfs' directory.
  # Full paths from the document root will be passed through.
  # Used internally by +swf_tag+ to build the swf path.
  #
  # ==== Examples
  #     swf_path("example")                            # => /swfs/example.swf
  #     swf_path("example.swf")                        # => /swfs/example.swf
  #     swf_path("fonts/optima")                       # => /swfs/fonts/optima.swf
  #     swf_path("/fonts/optima")                      # => /fonts/optima.swf
  #     swf_path("http://www.example.com/game.swf")    # => http://www.example.com/game.swf
  #
  # It takes into account the global setting +asset_host+, like any other asset:
  #
  #     ActionController::Base.asset_host = "http://assets.example.com"
  #     image_path("logo.jpg")                         # => http://assets.example.com/images/logo.jpg
  #     swf_path("fonts/optima")                       # => http://assets.example.com/swfs/fonts/optima.swf
  def swf_path(source)
    if respond_to? :path_to_asset
      path_to_asset(source, :ext => 'swf')
    else
      asset_paths.compute_public_path(source, 'swfs', :ext => 'swf')
    end
  end
  alias_method :path_to_swf, :swf_path # aliased to avoid conflicts with an image_path named route

  # Computes the full URL to a swf asset in the public swf directory.
  # This will use +swf_path+ internally, so most of their behaviors will be the same.
  def swf_url(source)
    URI.join(current_host, path_to_swf(source)).to_s
  end
  alias_method :url_to_swf, :swf_url # aliased to avoid conflicts with an swf_url named route
end
