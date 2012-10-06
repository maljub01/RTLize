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

      'border-left-color'                  => 'border-right-color',
      'border-right-color'                 => 'border-left-color',

      'border-radius-bottomleft'           => 'border-radius-bottomright',
      'border-radius-bottomright'          => 'border-radius-bottomleft',
      'border-bottom-right-radius'         => 'border-bottom-left-radius',
      'border-bottom-left-radius'          => 'border-bottom-right-radius',
      '-webkit-border-bottom-right-radius' => '-webkit-border-bottom-left-radius',
      '-webkit-border-bottom-left-radius'  => '-webkit-border-bottom-right-radius',
      '-moz-border-radius-bottomright'     => '-moz-border-radius-bottomleft',
      '-moz-border-radius-bottomleft'      => '-moz-border-radius-bottomright',

      'border-radius-topleft'              => 'border-radius-topright',
      'border-radius-topright'             => 'border-radius-topleft',
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
      'padding'               => :quad,
      'margin'                => :quad,
      'text-align'            => :rtltr,
      'float'                 => :rtltr,
      'clear'                 => :rtltr,
      'direction'             => :direction,
      'border-radius'         => :quad_radius,
      '-webkit-border-radius' => :quad_radius,
      '-moz-border-radius'    => :quad_radius,
      'box-shadow'            => :box_shadow,
      '-webkit-box-shadow'    => :box_shadow,
      '-moz-box-shadow'       => :box_shadow,
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

      def quad(v)
        # 1px 2px 3px 4px => 1px 4px 3px 2px
        m = v.split(/\s+/)
        m.length == 4 ? [m[0], m[3], m[2], m[1]].join(' ') : v
      end

      def quad_radius(v)
        # 1px 2px 3px 4px => 1px 2px 4px 3px
        # since border-radius: top-left top-right bottom-right bottom-left
        # will be border-radius: top-right top-left bottom-left bottom-right
        m = v.split(/\s+/)
        m.length == 4 ? [m[1], m[0], m[3], m[2]].join(' ') : v
      end

      def box_shadow(v)
        found = false
        v.gsub(/rgba\([^)]*\)|,|#\S*|[-0-9px]+/) do |m|
          if m == ","
            # this property can take several comma-seperated values, we account for that, and transform each one correctly.
            found = false
            m
          elsif m.match(/rgba\([^)]*\)|#\S*/) || found
            m
          else
            found = true
            m.to_i.zero? ? m : m.gsub(m.to_i.to_s, (-1 * m.to_i).to_s)
          end
        end
      end
    end
  end
end
