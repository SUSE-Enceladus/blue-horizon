# frozen_string_literal: true

require 'ruby_terraform'

class PlansController < ApplicationController
  before_action :config_terraform, only: [:show]
  before_action :init_terraform, only: [:show]

  def show; end

  private

  def config_terraform
    RubyTerraform.configure do |config|
      config.binary = '/usr/bin/terraform'
      config.logger = Logger.new(
        RubyTerraform::MultiIO.new(STDOUT),
        level: :debug
      )
      config.stdout = config.logger
      config.stderr = config.logger
    end
  end

  def init_terraform
    RubyTerraform.init(from_module: '', path: 'vendor/sources')
  end
end
