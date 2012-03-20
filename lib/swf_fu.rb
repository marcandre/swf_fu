module SwfFu
  class Engine < Rails::Engine
    # Thanks to http://robots.thoughtbot.com/post/159805560/tips-for-writing-your-own-rails-engine for:
    config.to_prepare do
      ActionView::Helpers.class_eval  { include SwfFuHelper }
    end
    # Thanks to http://jonswope.com/2010/07/25/rails-3-engines-plugins-and-static-assets/ for:
    initializer "static assets" do |app|
      app.middleware.use ::ActionDispatch::Static, "#{root}/public"
    end
  end

  ::ActionView::Base.cattr_accessor :swf_default_options
  ::ActionView::Base.swf_default_options = {}
end
