module Rtlize
  class Declaration
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
      def transform(property, value)
        # Get the property, without comments or spaces, to be able to find it.
        property_name = property.strip.split(' ').last.gsub(/^[*_]/, '')
        if @property_map[property_name]
          property = property.sub(property_name, @property_map[property_name])
        elsif @value_map[property_name]
          clean_value = value.sub(/;$/, '').sub(/\\9/, '').sub(/!\s*important/, '').strip
          value = value.sub(clean_value, self.send(@value_map[property_name], clean_value))
        end

        property + ':' + value
      end

      def transform_multiple(declarations)
        declarations.split(/(?<=;)(?!base64)/).map do |declaration|
          m = declaration.match(/([^:]+):(.+)/m)

          if m
            property, value = m[1..2]
            transform(property, value)
          else
            declaration
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
            if parts.size == 1
              # Using backwards compatible syntax
              parts = m.gsub(/[()]/, '').split(/\s+/).map(&:strip)
              "(#{parts[0]} #{parts[3]} #{parts[2]} #{parts[1]})"
            else
              "(#{parts[0]}, #{parts[3]}, #{parts[2]}, #{parts[1]})"
            end
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
