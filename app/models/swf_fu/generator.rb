module SwfFu
  DEFAULTS = {
    :width            => "100%",
    :height           => "100%",
    :flash_version    => 7,
    :mode             => :dynamic,
    :auto_install     => "expressInstall",
    :alt    => <<-"EOS".squeeze(" ").strip.freeze
      <a href="http://www.adobe.com/go/getflashplayer">
        <img src="http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif" alt="Get Adobe Flash player" />
      </a>
    EOS
  }.freeze
  
  class Generator # :nodoc:
    VALID_MODES = [:static, :dynamic]
    def initialize(source, options, view)
      @view = view
      @source = view.swf_path(source)
      options = ActionView::Base.swf_default_options.merge(options)
      options.each do |key, value|
        options[key] = value.call(source) if value.respond_to?(:call)
      end
      [:html_options, :parameters, :flashvars].each do |k|
        options[k] = convert_to_hash(options[k]).reverse_merge convert_to_hash(ActionView::Base.swf_default_options[k])
      end
      options.reverse_merge!(DEFAULTS)
      options[:id] ||= source.gsub(/^.*\//, '').gsub(/\.swf$/,'')
      options[:id] = force_to_valid_id(options[:id])
      options[:div_id] ||= options[:id]+"_div"
      options[:div_id] = force_to_valid_id(options[:div_id])
      options[:width], options[:height] = options[:size].scan(/^(\d*%?)x(\d*%?)$/).first if options[:size]
      options[:auto_install] &&= @view.swf_path(options[:auto_install])
      options[:flashvars][:id] ||= options[:id]
      @mode = options.delete(:mode)
      @options = options
      unless VALID_MODES.include? @mode
        raise ArgumentError, "options[:mode] should be either #{VALID_MODES.join(' or ')}"
      end
    end

    def force_to_valid_id(id)
      id = id.gsub /[^A-Za-z0-9\-_]/, "_" # HTML id can only contain these characters
      id = "swf_" + id unless id =~ /^[A-Z]/i # HTML id must start with alpha
      id
    end

    def generate(&block)
      @options[:alt] = @view.capture(&block) if block_given?
      send(@mode)
    end
    
  private
    def convert_to_hash(s)
      case s
        when Hash
          s
        when nil
          {}
        when String
          s.split("&").inject({}) do |h, kvp|
            key, value = kvp.split("=")
            h[key.to_sym] = CGI::unescape(value)
            h
          end
        else
          raise ArgumentError, "#{s} should be a Hash, a String or nil"
      end
    end
  
    def convert_to_string(h)
      h.map do |key_value|
        key_value.map{|val| CGI::escape(val.to_s)}.join("=")
      end.join("&")
    end
    
    def static
      param_list = @options[:parameters].map{|k,v| %(<param name="#{k}" value="#{v}"/>) }.join("\n")
      param_list += %(\n<param name="flashvars" value="#{convert_to_string(@options[:flashvars])}"/>) unless @options[:flashvars].empty?
      html_options = @options[:html_options].map{|k,v| %(#{k}="#{v}")}.join(" ")
      r = @view.javascript_tag(
        %(swfobject.registerObject("#{@options[:id]}_container", "#{@options[:flash_version]}", #{convert_to_escaped_arguments(@options[:auto_install])});)
      )
      r << <<-"EOS".strip.html_safe
        <div id="#{@options[:div_id]}"><object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" width="#{@options[:width]}" height="#{@options[:height]}" id="#{@options[:id]}_container" #{html_options}>
          <param name="movie" value="#{@source}" />
          #{param_list}
          <!--[if !IE]>-->
          <object type="application/x-shockwave-flash" data="#{@source}" width="#{@options[:width]}" height="#{@options[:height]}" id="#{@options[:id]}">
          #{param_list}
          <!--<![endif]-->
            #{@options[:alt]}
          <!--[if !IE]>-->
          </object>
          <!--<![endif]-->
        </object></div>
      EOS
      r << @view.javascript_tag(extend_js) if @options[:javascript_class]
      r << library_check
      r
    end
  
    def dynamic
      @options[:html_options] = @options[:html_options].merge(:id => @options[:id])
      @options[:parameters] = @options[:parameters].dup # don't modify the original parameters
      args = convert_to_escaped_arguments(@source,
                                          *@options.values_at(:div_id,:width,:height,:flash_version).map(&:to_s), 
                                          *@options.values_at(:auto_install,:flashvars,:parameters,:html_options)
                                          )

      preambule = @options[:switch_off_auto_hide_show] ? "swfobject.switchOffAutoHideShow();" : ""
      r = @view.javascript_tag(preambule + "swfobject.embedSWF(#{args})") 
      r << @view.content_tag("div", @options[:alt].html_safe, :id => @options[:div_id])
      r << @view.javascript_tag("swfobject.addDomLoadEvent(function(){#{extend_js}})") if @options[:javascript_class]
      r << library_check
      r
    end

    def convert_to_escaped_arguments(*values)
      # Note: Rails used to escape <>& but it's now a setting
      values.map(&:to_json).join(",").gsub('>', '\u003E').gsub('<', '\u003C').gsub('&', '\u0026')
    end

    def extend_js
      args = @options[:initialize]
      args = [args] unless args.is_a?(Array)
      "SwfFu.setup($('##{@options[:id]}')[0], #{@options[:javascript_class]}, [#{convert_to_escaped_arguments(*args)}])"
    end
  
    def library_check
      return "" unless 'development' == ENV['RAILS_ENV']
      @view.javascript_tag(<<-"EOS")
        if (typeof swfobject == 'undefined') {
          document.getElementById('#{@options[:div_id]}').innerHTML = '<strong>Warning:</strong> SWFObject.js was not loaded properly. Make sure you require "swfobject" in your main javascript file.';
        }
      EOS
    end
  end #class Generator
end