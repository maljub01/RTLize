require 'tilt'
require 'rtlize/rtlizer'

module Rtlize
  class RtlProcessor < Tilt::Template
    self.default_mime_type = 'text/css'

    def prepare; end

    def evaluate(scope, locals, &block)
      if scope.pathname.basename.to_s.match(/\.rtl\.css/i)
        Rtlize::RTLizer.transform(data)
      else
        data
      end
    end
  end
end
