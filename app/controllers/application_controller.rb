# frozen_string_literal: true

# Abstract class for centralizing ActionController customization
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authorize

  def authorize
    return if helpers.can(request.path)

    flash[:error] = t(:unauthorized)
    redirect_back(fallback_location: welcome_path)
  end
end
