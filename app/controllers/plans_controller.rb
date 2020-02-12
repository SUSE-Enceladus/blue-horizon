# frozen_string_literal: true

require 'ruby_terraform'

class PlansController < ApplicationController
  prepend_before_action :read_exported_vars
  prepend_before_action :read_exported_sources
  prepend_before_action :config_terraform
  before_action :init_terraform

  def show
    return unless @exported_vars

    info = terraform_plan
    return flash.now[:error] = info[:error] if info.is_a?(Hash)

    Dir.chdir(Rails.configuration.x.source_export_dir)
    # send show output to UI
    terraform_show
    Dir.chdir(Rails.root)
  end

  private

  def config_terraform
    log_path_filename = Rails.configuration.x.terraform_log_filename
    @log_file = Logger::LogDevice.new(log_path_filename)
    logger = Logger.new(
      RubyTerraform::MultiIO.new(STDOUT, @log_file),
      level: :debug
    )
    RubyTerraform.configure do |config|
      config.binary = find_default_binary
      config.logger = logger
      config.stdout = logger
      config.stderr = logger
    end
  end

  def init_terraform
    Dir.chdir(Rails.configuration.x.source_export_dir)
    RubyTerraform.init(
      from_module: '', path: Rails.configuration.x.source_export_dir
    )
    Dir.chdir(Rails.root)
  end

  def find_default_binary
    return `which terraform`.strip
  end

  def export_vars
    variables = Variable.load
    variables.export
  end

  def export_path
    exported_dir_path = Rails.configuration.x.source_export_dir
    exported_vars_file_path = Variable::DEFAULT_EXPORT_FILENAME
    return File.join(exported_dir_path, exported_vars_file_path)
  end

  def read_exported_vars
    export_vars
    export_var_path = export_path
    @exported_vars = nil
    if File.exist?(export_var_path)
      vars = File.read(export_var_path)
      @exported_vars = JSON.parse(vars)
    else
      message = 'There are no vars saved.'
      logger.error message
      flash.now[:error] = message
    end
  end

  def read_exported_sources
    sources = Source.all
    sources.each(&:export)
  end

  def terraform_plan
    Dir.chdir(Rails.configuration.x.source_export_dir)
    RubyTerraform.plan(
      directory: Rails.configuration.x.source_export_dir, vars: @exported_vars,
      plan: saved_plan_path
    )
    Dir.chdir(Rails.root)
  rescue RubyTerraform::Errors::ExecutionError
    return { error: 'Plan operation has failed' }
  end

  def terraform_show
    # change stdout to capture the output
    RubyTerraform.configuration.stdout = StringIO.new
    RubyTerraform.show(path: saved_plan_path, json: true)
    @show_output = RubyTerraform.configuration.stdout.string
    # back to DEFAULT configuration
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger
  end

  def saved_plan_path
    return Rails.root.join(
      Rails.configuration.x.source_export_dir,
      'current_plan'
    )
  end
end
