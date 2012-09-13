require 'rtlize/rtl_template'

module Rtlize
  class Railtie < ::Rails::Railtie
    config.before_initialize do |app|
      if app.config.assets.enabled
        require 'sprockets'
        require 'sprockets/engines'
        Sprockets.register_engine '.rtl', Rtlize::RtlTemplate
      end
    end
  end
end
