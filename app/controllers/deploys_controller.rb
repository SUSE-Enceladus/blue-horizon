# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController
  def show
    variables_file = read_exported_vars
    render :show, flash: { error: 'No plan has been created.' } unless
      File.exist?(variables_file)

    @exported_vars = JSON.parse(File.read(variables_file))
    terraform_tf_vars = Rails.root.join(
      Rails.configuration.x.source_export_dir,
      'terraform.tfvars'
    )
    RubyTerraform.apply(
      directory:  Rails.configuration.x.source_export_dir, vars: @exported_vars,
      vars_files: [terraform_tf_vars],
      auto_approve: false # change to TRUE to avoid interaction
    )
  end

  private

  def read_exported_vars
    exported_dir_path = Rails.configuration.x.source_export_dir
    exported_vars_file_path = Variable.new('').filename
    return File.join(exported_dir_path, exported_vars_file_path)
  end
end
