module Rtlize
  @@rtl_selector = "[dir=rtl]"
  @@rtl_locales  = [:ar, :fa, :he, :ur]

  def self.rtl_selector
    @@rtl_selector
  end

  def self.rtl_selector=(selector)
    @@rtl_selector = selector
  end

  def self.rtl_locales
    @@rtl_locales
  end

  def self.rtl_locales=(locales)
    @@rtl_locales = locales
  end

  class RTLizer
    class << self
      def should_rtlize_selector?(selector)
        selector = selector.gsub(/\/\*[\s\S]+?\*\//, '') # Remove comments
        selector = selector.gsub(/['"]/, '') # Remove quote characters

        rtl_selector = Rtlize.rtl_selector.gsub(/['"]/, '') # Remove quote characters

        rtl_selector_regexp = /(^|\b|\s)#{Regexp.escape(rtl_selector)}($|\b|\s)/
        !selector.match(rtl_selector_regexp)
      end

      def update_no_invert(selector)
        # The CSS comment must start with "!" in order to be considered as important by the CSS compressor
        # otherwise, it will be removed by the asset pipeline before reaching this processor.
        if selector.match(/\/\*!= begin\(no-rtl\) \*\//)
          @no_invert = true
        elsif selector.match(/\/\*!= end\(no-rtl\) \*\//)
          @no_invert = false
        end
      end

      def transform(css)
        @no_invert = false

        block_re = %r{
          (?<block>
            [^\{\}]+ \{
              (?:
                \g<block>* [^\{\}]*
                |
                [^\{\}]+
              )
            \}
          )
        }x

        css.gsub(block_re) do |block|
          block_selector_re = %r{ ^ [^\{\}]+ }x
          block_selector = block.match(block_selector_re).to_s
          next if block_selector.length == 0

          # Break the blocks' rules into their selector & declaration parts
          rule_re = %r{
            ( [^\{\}]+ ) \{
              (
                (?:
                  [^\{\}]+ \{
                    [^\{\}]+
                  \} [^\{\}]*
                )*
              )
            \}
            |
            ( [^\{\}]+ ) \{
              ( [^\{\}]+ )
            \}
          }x

          block.gsub(rule_re) do |rule|
            parts = rule.match(rule_re)
            if parts[1].nil?
              # Simple block
              selector, declarations = parts[3,4]
              transform_simple_block(selector, declarations)
            else
              # Nested blocks
              selector, declarations = parts[1,2]
              selector + '{' + transform_nested_blocks(declarations) + '}'
            end
          end
        end
      end

      def transform_simple_block(selector, declarations)
        update_no_invert(selector)
        if !@no_invert && should_rtlize_selector?(selector)
          selector + '{' + Rtlize::Declaration.transform_multiple(declarations) + '}'
        else
          selector + '{' + declarations + '}'
        end
      end

      def transform_nested_blocks(blocks)
        simple_block_re = %r{
          ( [^\{\}]+ ) \{
            ( [^\{\}]+ )
          \}
        }x
        blocks.gsub(simple_block_re) do |block|
          parts = block.match(simple_block_re)
          selector, declarations = parts[1,2]
          transform_simple_block(selector, declarations)
        end
      end
    end
  end
end
