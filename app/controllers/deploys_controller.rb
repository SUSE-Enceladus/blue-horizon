# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController
  def show
    variables_file = exported_vars_path
    render :show, flash: { error: 'No plan has been created.' } unless
      File.exist?(variables_file)
    read_exported_vars(variables_file)

    auto_approve = false
    RubyTerraform.apply(
      directory:  Rails.configuration.x.source_export_dir, vars: JSON.parse(
        @exported_vars
      ),
      vars_files: [@terraform_tf_vars],
      auto_approve: auto_approve # change to TRUE to avoid interaction
    )
  rescue RubyTerraform::Errors::ExecutionError
    raise if auto_approve

    logger.warn 'Remember to auto approve the deploy.'
  end

  private

  def exported_vars_path
    exported_dir_path = Rails.configuration.x.source_export_dir
    exported_vars_file_path = Variable.new('').filename
    return File.join(exported_dir_path, exported_vars_file_path)
  end

  def read_exported_vars(variables_file)
    @exported_vars = File.read(variables_file)
    logger.info(@exported_vars)
    @terraform_tf_vars = Rails.root.join(
      Rails.configuration.x.source_export_dir,
      'terraform.tfvars'
    )
  end
end
