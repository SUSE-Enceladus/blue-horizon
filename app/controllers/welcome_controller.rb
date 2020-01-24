# frozen_string_literal: true

class WelcomeController < ApplicationController
  def index; end

  def advanced
    Rails.configuration.x.advanced_mode = true
    redirect_to sources_path
  end

  def simple
    Rails.configuration.x.advanced_mode = false
    redirect_to cluster_path
  end
end
