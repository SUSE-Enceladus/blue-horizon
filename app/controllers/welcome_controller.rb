# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index; end

  def reset_session
    helpers.set_session!
    flash[:alert] = t(:session_reset)
    redirect_to welcome_path
  end
end
