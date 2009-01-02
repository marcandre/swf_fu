module ActionView #:nodoc:
  module Helpers # :nodoc:
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
      # * <tt>:fallback_html</tt> - HTML text that is displayed when the Flash player is not available. Defaults to a "Get Flash" image pointing to Adobe Flash's installation page.
      # * <tt>:flash_version</tt> - the version of the Flash player that is required (e.g. "7" (default) or "8.1.0")
      # * <tt>:auto_install</tt> - a swf file that will upgrade flash player if needed (defaults to "expressInstall" which was installed by swf_fu)
      # * <tt>:javascript_class</tt> - specify a javascript class (e.g. "MyFlash") for your flash object. The initialize method will be called when the flash object is ready.
      # * <tt>:initialize</tt> - arguments to pass to the initialization method of your javascript class.
      # * <tt>:div_id</tt> - the DOM +id+ of the containing div itself. Defaults to <tt>"#{option[:id]}"_div</tt>
      def swf_tag(source, options={})
        Generator.new(source, options, self).generate
      end

      # For compatibility with the older FlashObject.
      # It modifies the given options before calling +swf_tag+.
      def flashobject_tag_for_compatibility(source, options={})
        options = options.reverse_merge(
          :auto_install     => nil,
          :parameters       => {:scale => "noscale"},
          :variables        => {:lzproxied => false},
          :flash_id         => "flashcontent_#{rand(1_100)}",
          :background_color => "#ffffff"
        )
        { :variables => :flashvars, :flash_id => :id }.each{|from, to| options[to] ||= options.delete(from) }
        options[:parameters][:bgcolor] ||= options.delete(:background_color)
        swf_tag source, options
      end
    
      alias_method :flashobject_tag, :flashobject_tag_for_compatibility unless defined? flashobject_tag
    
  private
      class Generator # :nodoc:
        VALID_MODES = [:static, :dynamic]
        def initialize(source, options, view)
          @view = view
          @source = view.swf_path(source)
          @options = ActionView::Base.swf_default_options.merge(options)
          [:html_options, :parameters, :flashvars].each do |k|
            @options[k].merge! ActionView::Base.swf_default_options[k] rescue "merge won't work for string or nil, ignore error"
          end
          @options.reverse_merge!(
            :id               => source.gsub(/^.*\//, '').gsub(/\.swf$/,''),
            :width            => "100%",
            :height           => "100%",
            :flash_version    => 7,
            :parameters       => {},
            :flashvars        => {},
            :html_options     => {},
            :mode             => :dynamic,
            :auto_install     => "expressInstall",
            :fallback_html    => <<-"EOS"
              <a href="http://www.adobe.com/go/getflashplayer">
            	  <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
              </a>
            EOS
          )
          @options[:div_id] ||= @options[:id]+"_div"
          @options[:width], @options[:height] = @options[:size].scan(/^(\d*%?)x(\d*%?)$/).first if @options[:size]
          @options[:auto_install] &&= @view.swf_path(@options[:auto_install])
          if @options[:flashvars].is_a?(Hash)
            @options[:flashvars] = @options[:flashvars].map do |key_value|
              key_value.map{|val| CGI::escape(val.to_s)}.join("=")
            end.join("&")
          end
          @mode = @options.delete(:mode)
          unless VALID_MODES.include? @mode
            raise ArgumentError, "options[:mode] should be either #{VALID_MODES.join(' or ')}"
          end
        end

        def generate
          send(@mode) + (
            'development' == ENV['RAILS_ENV'] ? library_check : ""
          )
        end
      private
        def static
          param_list = @options[:parameters].map{|k,v| %(<param name="#{k}" value="#{v}"/>) }.join("\n")
          param_list += %(\n<param name="flashvars" value="#{@options[:flashvars]}"/>) unless @options[:flashvars].empty?
          html_options = @options[:html_options].map{|k,v| %(#{k}="#{v}")}.join(" ")
          r = @view.javascript_tag(%(swfobject.registerObject("#{@options[:id]}_container", "#{@options[:flash_version]}", #{@options[:auto_install].to_json});)) + <<-"EOS"
          
            <div id="#{@options[:div_id]}"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="#{@options[:width]}" height="#{@options[:height]}" id="#{@options[:id]}_container" #{html_options}>
              <param name="movie" value="#{@source}" />
              #{param_list}
              <!--[if !IE]>-->
              <object type="application/x-shockwave-flash" data="#{@source}" width="#{@options[:width]}" height="#{@options[:height]}" id="#{@options[:id]}">
              #{param_list}
              <!--<![endif]-->
                #{@options[:fallback_html]}
              <!--[if !IE]>-->
              </object>
              <!--<![endif]-->
            </object></div>
          EOS
          r += @view.javascript_tag extend_js if @options[:javascript_class]
          r
        end
      
        def dynamic
          @options[:html_options] = @options[:html_options].merge(:id => @options[:id])
          args = (([@source] + @options.values_at(:div_id,:width,:height,:flash_version)).map(&:to_s) + 
                  @options.values_at(:auto_install,:flashvars,:parameters,:html_options)
                 ).map(&:to_json).join(",")
          r = @view.javascript_tag("swfobject.embedSWF(#{args})") 
          r += <<-"EOS"
        
            <div id="#{@options[:div_id]}">
              #{@options[:fallback_html]}
            </div>
          EOS
          r += @view.javascript_tag("swfobject.addDomLoadEvent(function(){#{extend_js}})") if @options[:javascript_class]
          r
        end
      
        def extend_js
          "Object.extend($('#{@options[:id]}'), #{@options[:javascript_class]}.prototype).initialize(#{@options[:initialize].to_json})"
        end
      
        def library_check
          @view.javascript_tag <<-"EOS"
            if (typeof swfobject == 'undefined') {
              document.getElementById('#{@options[:div_id]}').innerHTML = '<strong>Warning:</strong> SWFObject.js was not loaded properly. Make sure you <tt>&lt;%= javascript_include_tag :defaults %></tt> or <tt>&lt;%= javascript_include_tag :swfobject %></tt>';
            }
          EOS
        end
      end #class Generator
    end
  end
end