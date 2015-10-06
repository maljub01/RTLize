module Rtlize
  class RtlProcessor
    attr_reader :data

    def initialize(file, &block)
      @data = block.call
    end

    def render(context)
      if context.pathname.basename.to_s.match(/\.rtl\.css/i) || context.pathname.basename.to_s.match(/\.rtl\.scss/i)
        Rtlize::RTLizer.transform(data)
      else
        data
      end
    end
  end
end
