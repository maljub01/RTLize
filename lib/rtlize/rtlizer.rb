require 'rtlize/declaration'

module Rtlize
  def self.rtl_selector
    @@rtl_selector ||= "[dir=rtl]"
  end

  def self.rtl_selector=(selector)
    @@rtl_selector = selector
  end

  def self.rtl_locales
    @@rtl_locales ||= [:ar, :fa, :he, :ur]
  end

  def self.rtl_locales=(locales)
    @@rtl_locales = locales
  end

  class RTLizer
    class << self
      def simple_block_regexp
        %r{
          ( [^\{\}]+ ) \{
            ( [^\{\}]+ )
          \}
        }x
      end

      def block_regexp
        %r{
          [^\{\}]+ \{
            (?:
              (?:
                [^\{\}]+ \{
                  [^\}]*
                \} [^\{\}]*
              )*
              |
              [^\{\}]+
            )
          \}
        }x
      end

      def rule_regexp
        # Break the blocks' rules into their selector & declaration parts
        %r{
          ( [^\{\}]+ ) \{
            (
              (?:
                [^\{\}]+ \{
                  [^\}]*
                \} [^\{\}]*
              )*
            )
          \}
          |
          ( [^\{\}]+ ) \{
            ( [^\{\}]+ )
          \}
        }x
      end

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

        css.gsub(block_regexp) do |block|
          block_selector_regexp = %r{ ^ [^\{\}]+ }x
          block_selector = block.match(block_selector_regexp).to_s
          next if block_selector.length == 0

          block.gsub(rule_regexp) do |rule|
            parts = rule.match(rule_regexp)
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
        blocks.gsub(simple_block_regexp) do |block|
          parts = block.match(simple_block_regexp)
          selector, declarations = parts[1,2]
          transform_simple_block(selector, declarations)
        end
      end
    end
  end
end
