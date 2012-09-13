require 'tilt'
require 'sprockets'
require 'rtlize/rtlizer'

module Rtlize
  class RtlTemplate < Tilt::Template
    self.default_mime_type = 'text/css'

    def prepare; end

    def evaluate(scope, locals, &block)
      Rtlize::RTLizer.transform(data)
    end
  end
end
