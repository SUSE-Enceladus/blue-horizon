# frozen_string_literal: true

require 'ruby_terraform'
require 'fileutils'

class PlansController < ApplicationController
  include FileUtils

  def show
    return unless helpers.can(deploy_path)

    Terraform.new.show(saved_plan_path)
    @show_output = Terraform.stdout.string
    @show_output = JSON.pretty_generate(JSON.parse(@show_output))

    respond_to do |format|
      format.html
      format.json do
        send_data(
          @show_output,
          disposition: 'attachment',
          filename:    'terraform_plan.json'
        )
      end
    end
  end

  def update
    prep
    return unless @exported_vars

    terra = Terraform.new
    result = terra.plan(
      Rails.configuration.x.source_export_dir,
      saved_plan_path
    )

    if result.is_a?(Hash)
      flash.now[:error] = result[:error]
      return render json: flash.to_hash
    end
    terra.show(saved_plan_path)
    @show_output = Terraform.stdout.string
    @show_output = JSON.pretty_generate(JSON.parse(@show_output))

    respond_to do |format|
      format.html { render :show }
      format.js   { render json: @show_output }
    end
  end

  private

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
      logger.error t('flash.export_failure')
      flash.now[:error] = t('flash.export_failure')
      return render json: flash.to_hash
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
  end

  def saved_plan_path
    return Rails.configuration.x.source_export_dir.join('current_plan')
  end
end
