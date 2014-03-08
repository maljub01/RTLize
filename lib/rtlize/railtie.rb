module Rtlize
  class Railtie < ::Rails::Railtie
    config.rtlize = ActiveSupport::OrderedOptions.new
    config.rtlize.rtl_selector = Rtlize.rtl_selector
    config.rtlize.rtl_locales  = Rtlize.rtl_locales

    initializer "rtlize.railtie", :after => "sprockets.environment" do |app|
      if app.config.assets.enabled
        app.assets.register_postprocessor 'text/css', Rtlize::RtlProcessor
      end

      Rtlize.rtl_selector = config.rtlize.rtl_selector
      Rtlize.rtl_locales  = config.rtlize.rtl_locales
    end
  end
end
