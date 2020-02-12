# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController
  def pre_deploy
    RubyTerraform.configuration.stdout = StringIO.new
    @apply_args = {
      directory: Rails.configuration.x.source_export_dir, auto_approve: true
    }
    variables_file = exported_vars_path

    return render json: { error: 'No plan has been created.' } unless
      File.exist?(variables_file)

    read_exported_vars(variables_file)
    logger.info('Calling run_deploy')
    run_deploy
  end

  def send_current_status
    return render json: { info: RubyTerraform.configuration.stdout.string } if
      RubyTerraform.configuration.stdout.is_a?(StringIO)

    return render json: { info: @apply_output } unless @apply_output.nil?
  end

  private

  def run_deploy
    Dir.chdir(Rails.configuration.x.source_export_dir)
    terraform_apply
    Dir.chdir(Rails.root)
  end

  def exported_vars_path
    exported_dir_path = Rails.configuration.x.source_export_dir
    exported_vars_file_path = Variable::DEFAULT_EXPORT_FILENAME
    return File.join(exported_dir_path, exported_vars_file_path)
  end

  def read_exported_vars(variables_file)
    @exported_vars = File.read(variables_file)
    @apply_args[:vars] = JSON.parse(@exported_vars)
    @apply_args[:vars_files] = ['terraform.tfvars']
  end

  def terraform_apply
    RubyTerraform.apply(@apply_args)
    @apply_output = RubyTerraform.configuration.stdout.string
    sleep(7)
    # back to DEFAULT configuration
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger

    write_output('/tmp/ruby-terraform.log')
  rescue RubyTerraform::Errors::ExecutionError
    render json: { error: 'Deploy operation has failed.' }
  end

  def write_output(log_file)
    # write the output of terraform apply
    # in STDOUT and file
    f = File.open(log_file, 'a')
    f.write(@apply_output)
    logger.info @apply_output
  end
end
