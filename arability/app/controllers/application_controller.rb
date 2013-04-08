class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :set_locale

  def set_locale
    if params[:locale].nil?
      if session[:locale].nil?
        I18n.locale = :ar
      else
        I18n.locale = session[:locale]
      end
    else
      I18n.locale = params[:locale]
      session[:locale] = params[:locale]
    end
  end

  def default_url_options(options={})
    logger.debug "default_url_options is passed options: #{options.inspect}\n"
    { :locale => I18n.locale }
  end
end
