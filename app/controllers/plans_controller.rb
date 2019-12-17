# frozen_string_literal: true

require 'ruby_terraform'

class PlansController < ApplicationController
  before_action :config_terraform
  before_action :init_terraform
  before_action :read_exported_vars
  before_action :read_exported_sources

  def show
    return unless @exported_vars

    terraform_plan
    Dir.chdir(Rails.configuration.x.source_export_dir)
    terraform_show
    Dir.chdir(Rails.root)
    # send show output to UI
  end

  private

  def config_terraform
    @log_file = File.open(log_path_filename, 'a')
    @log_file.sync = true # implicit flushing, no buffering
    RubyTerraform.configure do |config|
      config.binary = find_default_binary
      config.logger = Logger.new(
        RubyTerraform::MultiIO.new(STDOUT, @log_file),
        level: :debug
      )
      config.stdout = config.logger
      config.stderr = config.logger
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

  def log_path_filename
    '/tmp/ruby-terraform.log'
  end

  def export_vars
    variables = Variable.load
    variables.export
  end

  def export_path
    exported_dir_path = Rails.configuration.x.source_export_dir
    exported_vars_file_path = Variable.new('').filename
    return File.join(exported_dir_path, exported_vars_file_path)
  end

  def read_exported_vars
    export_vars
    export_var_path = export_path
    if File.exist?(export_var_path)
      vars = File.read(export_var_path)
      @exported_vars = JSON.parse(vars)
    else
      @exported_vars = nil
      flash.now[:error] = 'There are no vars saved.'
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
  end

  def terraform_show
    # change stdout to capture the output
    RubyTerraform.configuration.stdout = StringIO.new
    RubyTerraform.show(path: saved_plan_path, json: true)
    @show_output = RubyTerraform.configuration.stdout.string
    # back to DEFAULT configuration
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger
    write_output
  end

  def write_output
    # write in STDOUT and file, the output of terraform show
    f = File.open(@log_file, 'a')
    f.write(@show_output)
    logger.info @show_output
  end

  def saved_plan_path
    return Rails.root.join(
      Rails.configuration.x.source_export_dir,
      'current_plan'
    )
  end
end
