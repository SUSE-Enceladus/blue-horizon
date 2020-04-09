# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController
  def update
    logger.info('Calling run_deploy')
    @apply_args = {
      directory:    Rails.configuration.x.source_export_dir,
      auto_approve: true,
      no_color:     true
    }
    Terraform.new.apply(@apply_args)
    logger.info('Deploy finished.')
  end

  def send_current_status
    if Terraform.stderr.is_a?(StringIO) && !Terraform.stderr.string.empty?
      error = Terraform.stderr.string
      content = error
    elsif Terraform.stdout.is_a?(StringIO)
      @apply_output = Terraform.stdout.string
      content = @apply_output
    end

    success = Terraform.stdout.string.include? 'Apply complete!'
    write_output(content, success)
    set_default_logger_config
    html = (render_to_string partial: 'output.html.haml')
    respond_to do |format|
      format.json do
        render json: { new_html: html, success: success,
                       error: error }
      end
    end
    return
  end

  private

  def set_default_logger_config
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger
    RubyTerraform.configuration.stderr = RubyTerraform.configuration.logger
  end

  def write_output(content, success)
    # write the output of terraform apply
    # in STDOUT and file
    f = File.open(Rails.configuration.x.terraform_log_filename, 'a')
    f.write(content)
    if success
      logger.info content
    else
      logger.error content
    end
  end
end
