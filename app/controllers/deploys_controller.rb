# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController
  def show
    @apply_args = {
      directory: Rails.configuration.x.source_export_dir, auto_approve: true
    }
    variables_file = exported_vars_path
    render :show, flash: { error: 'No plan has been created.' } unless
      File.exist?(variables_file)
    read_exported_vars(variables_file)

    Dir.chdir(Rails.configuration.x.source_export_dir)
    terraform_apply
    Dir.chdir(Rails.root)
  end

  private

  def exported_vars_path
    exported_dir_path = Rails.configuration.x.source_export_dir
    exported_vars_file_path = Variable.new('').filename
    return File.join(exported_dir_path, exported_vars_file_path)
  end

  def read_exported_vars(variables_file)
    logger.info(variables_file)
    @exported_vars = File.read(variables_file)
    logger.info(@apply_args)
    @apply_args[:vars] = JSON.parse(@exported_vars)
    logger.info(@exported_vars)
    @apply_args[:vars_files] = ['terraform.tfvars']
  end

  def terraform_apply
    RubyTerraform.configuration.stdout = StringIO.new

    RubyTerraform.apply(@apply_args)

    @apply_output = RubyTerraform.configuration.stdout.string
    # back to DEFAULT configuration
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger

    write_output('/tmp/ruby-terraform.log')

    show_apply_output
  rescue RubyTerraform::Errors::ExecutionError
    render :show, flash: { error: 'Apply has failed.' }
  end

  def write_output(log_file)
    # write the output of terraform apply in STDOUT and file
    f = File.open(log_file, 'a')
    f.write(@apply_output)
    logger.info @apply_output
  end

  def show_apply_output
    render :show, flash: { error: 'Apply did not execute correctly.' } unless
      File.exist?('terraform.tfstate')

    @terraform_tfstate = File.read('terraform.tfstate')
    logger.info(@terraform_tfstate)
  end
end
