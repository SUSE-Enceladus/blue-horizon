# frozen_string_literal: true

require 'ruby_terraform'
require 'fileutils'

class PlansController < ApplicationController
  include FileUtils

  def show
    terraform_show
    @current_plan = JSON.pretty_generate(JSON.parse(@show_output))
  rescue RubyTerraform::Errors::ExecutionError, JSON::ParserError
    @current_plan = ''
  ensure
    name = 'terraform_plan.json'
    respond_to do |format|
      format.html
      format.json do
        send_data @current_plan, disposition: 'attachment', filename: name
      end
    end
  end

  def update
    prep
    init_terraform
    return unless @exported_vars

    info = terraform_plan
    return flash.now[:error] = info[:error] if info.is_a?(Hash)

    terraform_show
    @current_plan = JSON.pretty_generate(JSON.parse(@show_output))

    respond_to do |format|
      format.html { render :show }
      format.js   { render json: @current_plan }
    end
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

  def cleanup
    exports = Rails.configuration.x.source_export_dir.join('*')
    Rails.logger.debug("cleaning up #{exports}")
    rm_r(Dir.glob(exports), secure: true)
  end

  def prep
    cleanup
    read_exported_vars
    read_exported_sources
    config_terraform
  end

  def terraform_plan
    Dir.chdir(Rails.configuration.x.source_export_dir)
    result = RubyTerraform.plan(
      directory: Rails.configuration.x.source_export_dir, vars: @exported_vars,
      plan: saved_plan_path
    )
    return result
  rescue RubyTerraform::Errors::ExecutionError
    return { error: 'Plan operation has failed' }
  ensure
    Dir.chdir(Rails.root)
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
    return Rails.configuration.x.source_export_dir.join('current_plan')
  end
end
