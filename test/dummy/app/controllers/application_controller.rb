class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def set_locale
    I18n.locale = if params[:locale].try(:to_sym).in?(I18n.available_locales)
      params[:locale]
    else
      I18n.default_locale
    end
  end
end
