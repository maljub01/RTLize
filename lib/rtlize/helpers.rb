module Rtlize
  def self.dir(locale = I18n.locale)
    Rtlize.rtl_locales.include?(locale.to_sym) ? 'rtl' : 'ltr'
  end
end
