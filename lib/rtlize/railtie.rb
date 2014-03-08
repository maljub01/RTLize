module Rtlize
  class Railtie < ::Rails::Railtie
    initializer "rtlize.railtie", :after => "sprockets.environment" do |app|
      if app.config.assets.enabled
        app.assets.register_preprocessor 'text/css', Rtlize::RtlProcessor
      end
    end
  end
end
