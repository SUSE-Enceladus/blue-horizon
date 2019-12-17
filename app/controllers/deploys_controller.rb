# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController
  def show
    variables_file = exported_vars_path
    render :show, flash: { error: 'No plan has been created.' } unless
      File.exist?(variables_file)
    read_exported_vars(variables_file)

    terraform_apply
    show_apply_output
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
    logger.info(@exported_vars)
    @terraform_tf_vars = 'terraform.tfvars'
  end

  def terraform_apply
    auto_approve = true
    Dir.chdir(Rails.configuration.x.source_export_dir)
    RubyTerraform.configuration.stdout = StringIO.new
    RubyTerraform.apply(
      directory:  Rails.configuration.x.source_export_dir, vars: JSON.parse(
        @exported_vars
      ),
      vars_files: [@terraform_tf_vars],
      auto_approve: auto_approve # change to TRUE to avoid interaction
    )
    @apply_output = RubyTerraform.configuration.stdout.string
    # back to DEFAULT configuration
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger
    write_output('/tmp/ruby-terraform.log')
    Dir.chdir(Rails.root)
  rescue RubyTerraform::Errors::ExecutionError
    raise if auto_approve

    logger.warn 'Remember to auto approve the deploy.'
  end

  def write_output(log_file)
    # write the output of terraform apply in STDOUT and file
    f = File.open(log_file, 'a')
    f.write(@apply_output)
    logger.info @apply_output
  end

  def show_apply_output
    Dir.chdir(Rails.configuration.x.source_export_dir)
    render :show, flash: { error: 'Apply did not execute correctly.' } unless
      File.exist?('terraform.tfstate')

    @terraform_tfstate = File.read('terraform.tfstate')
    logger.info(@terraform_tfstate)
    Dir.chdir(Rails.root)
  end
end
