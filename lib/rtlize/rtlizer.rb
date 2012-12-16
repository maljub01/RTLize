module Rtlize
  # Originally ported from http://github.com/ded/R2
  class RTLizer
    @property_map = {
      'margin-left'                        => 'margin-right',
      'margin-right'                       => 'margin-left',

      'padding-left'                       => 'padding-right',
      'padding-right'                      => 'padding-left',

      'border-left'                        => 'border-right',
      'border-right'                       => 'border-left',

      'border-left-width'                  => 'border-right-width',
      'border-right-width'                 => 'border-left-width',

      'border-left-style'                  => 'border-right-style',
      'border-right-style'                 => 'border-left-style',

      'border-left-color'                  => 'border-right-color',
      'border-right-color'                 => 'border-left-color',

      'border-bottom-right-radius'         => 'border-bottom-left-radius',
      'border-bottom-left-radius'          => 'border-bottom-right-radius',
      '-webkit-border-bottom-right-radius' => '-webkit-border-bottom-left-radius',
      '-webkit-border-bottom-left-radius'  => '-webkit-border-bottom-right-radius',
      '-moz-border-radius-bottomright'     => '-moz-border-radius-bottomleft',
      '-moz-border-radius-bottomleft'      => '-moz-border-radius-bottomright',

      'border-top-right-radius'            => 'border-top-left-radius',
      'border-top-left-radius'             => 'border-top-right-radius',
      '-webkit-border-top-right-radius'    => '-webkit-border-top-left-radius',
      '-webkit-border-top-left-radius'     => '-webkit-border-top-right-radius',
      '-moz-border-radius-topright'        => '-moz-border-radius-topleft',
      '-moz-border-radius-topleft'         => '-moz-border-radius-topright',

      'left'                               => 'right',
      'right'                              => 'left',
    }

    @value_map = {
      'border-color'          => :quad,
      'border-style'          => :quad,
      'border-width'          => :quad,
      'padding'               => :quad,
      'margin'                => :quad,
      'clip'                  => :rect,
      'cursor'                => :cursor,
      'text-align'            => :rtltr,
      'float'                 => :rtltr,
      'clear'                 => :rtltr,
      'direction'             => :direction,
      'border-radius'         => :quad_radius,
      '-webkit-border-radius' => :quad_radius,
      '-moz-border-radius'    => :quad_radius,
      'box-shadow'            => :shadow,
      '-webkit-box-shadow'    => :shadow,
      '-moz-box-shadow'       => :shadow,
      'text-shadow'           => :shadow,
      '-webkit-text-shadow'   => :shadow,
      '-moz-text-shadow'      => :shadow,
      'rotation'              => :deg,
    }

    class << self
      def transform(css)
        no_invert = false
        css.gsub(/([^{]+\{[^}]+\})+?/) do |rule|
          # Break rule into selector|declaration parts
          parts = rule.match(/([^{]+)\{([^}]+)/)
          if parts && !parts[1].gsub(/\/\*[\s\S]+?\*\//, '').match(/\.rtl\b/) # Don't transform rules that include the selector ".rtl" (remove comments first)
            selector, declarations = parts[1..2]

            # The CSS comment must start with "!" in order to be considered as important by the YUI compressor, otherwise, it will be removed by the asset pipeline before reaching this processor.
            if selector.match(/\/\*!= begin\(no-rtl\) \*\//)
              no_invert = true
              # selector.gsub!(/\/\*!= begin\(no-rtl\) \*\//, '')
            elsif selector.match(/\/\*!= end\(no-rtl\) \*\//)
              no_invert = false
              # selector.gsub!(/\/\*!= end\(no-rtl\) \*\//, '')
            end

            selector + '{' + self.transform_declarations(declarations, no_invert) + '}'
          else
            rule
          end
        end
      end

      def transform_declarations(declarations, no_invert = false)
        declarations.split(/;(?!base64)/).map do |decl|
          m = decl.match(/([^:]+):(.+)$/)

          if m && !no_invert
            prop, val = m[1..2]
            # Get the property, without comments or spaces, to be able to find it.
            prop_name = prop.strip.split(' ').last
            if @property_map[prop_name]
              prop = prop.sub(prop_name, @property_map[prop_name])
            end

            if @value_map[prop_name]
              val = val.sub(val.strip, self.send(@value_map[prop_name], val.strip))
            end

            prop + ':' + val + ';'
          elsif m
            decl + ';'
          else
            decl
          end
        end.join
      end

      def rtltr(v)
        v == 'left' ? 'right' : v == 'right' ? 'left' : v
      end

      def direction(v)
        v == 'ltr' ? 'rtl' : v == 'rtl' ? 'ltr' : v
      end

      def rect(v)
        if v.match(/rect\([^)]*\)/)
          v.gsub(/\([^)]*\)/) do |m|
            parts = m.gsub(/[()]/, '').split(',').map(&:strip)
            "(#{parts[0]}, #{parts[3]}, #{parts[2]}, #{parts[1]})"
          end
        else
          v
        end
      end

      def quad(v)
        # 1px 2px 3px 4px => 1px 4px 3px 2px
        m = v.split(/\s+/)
        m.length == 4 ? [m[0], m[3], m[2], m[1]].join(' ') : v
      end

      def quad_radius(v)
        # top-left, top-right, bottom-right, bottom-left
        # when bottom-left is omitted, it takes the value of top-right
        # when bottom-right is omitted, it takes the value of top-left
        # when top-right is omitted, it takes the value of top-left
        m = v.split(/\s+/)
        case m.length
        when 4 then [m[1], m[0], m[3], m[2]].join(' ')
        when 3 then [m[1], m[0], m[1], m[2]].join(' ')
        when 2 then [m[1], m[0]].join(' ')
        else v
        end
      end

      def cursor(v)
        if v.match(/^[ns]?e-resize$/)
          v.gsub(/e-resize/, 'w-resize')
        elsif v.match(/^[ns]?w-resize$/)
          v.gsub(/w-resize/, 'e-resize')
        else
          v
        end
      end

      def shadow(v)
        found = false
        v.gsub(/rgba\([^)]*\)|,|#[0-9A-Fa-f]*|[-0-9.px]+/) do |m|
          if m == ","
            # this property can take several comma-seperated values, we account for that, and transform each one correctly.
            found = false
            m
          elsif m.match(/rgba\([^)]*\)|#[0-9A-Fa-f]*/) || found
            m
          else
            found = true
            if m.to_f.zero?
              m
            else
              m.chars.first == '-' ? m[1..-1] : '-' + m
            end
          end
        end
      end

      def deg(v)
        if v == '0'
          v
        else
          old_angle = v.to_f
          new_angle = 360 - old_angle
          new_angle = new_angle.to_i if new_angle == new_angle.to_i # If it's an integer, write it without a decimal part.
          v.gsub(/[0-9.]+/, new_angle.to_s)
        end
      end
    end
  end
end
