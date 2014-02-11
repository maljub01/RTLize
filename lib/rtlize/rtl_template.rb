require 'tilt'
require 'sprockets'
require 'rtlize/rtlizer'

module Rtlize
  class RtlTemplate < Tilt::Template
    self.default_mime_type = 'text/css'

    def prepare; end

    def evaluate(scope, locals, &block)
      if scope.logical_path.match(/\.rtl$/i)
        Rtlize::RTLizer.transform(data)
      else
        data
      end
    end
  end
end
