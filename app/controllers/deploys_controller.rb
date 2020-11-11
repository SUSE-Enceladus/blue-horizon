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
    terra = Terraform.new
    # rubocop:disable Style/ClassVars
    @@planned_resources = terra.get_planned_resources.count
    # rubocop:enable Style/ClassVars
    terra.apply(@apply_args)
    logger.info('Deploy finished.')
  end

  def send_current_status
    if Terraform.stderr.is_a?(StringIO) && !Terraform.stderr.string.empty?
      error = Terraform.stderr.string
      content = error
      success = false
      write_output(content, success)
    elsif Terraform.stdout.is_a?(StringIO)
      @apply_output = Terraform.stdout.string
      content = @apply_output
      success = content.include? 'Apply complete!'
    end

    progress = update_terraform_progress(content, error)

    if success
      write_output(content, success)
      set_default_logger_config
    end
    html = (render_to_string partial: 'output.html.haml')

    respond_to do |format|
      format.json do
        render json: { new_html: html, progress: progress,
                       success: success, error: error }
      end
    end
    return
  end

  def destroy
    flash.now[:error] = Terraform.new.destroy
    unless flash.now[:error]
      flash.now[:notice] = 'Terraform resources have been destroyed.'
    end
    render :show
  end

  private

  def set_default_logger_config
    RubyTerraform.configuration.stdout = RubyTerraform.configuration.logger
    RubyTerraform.configuration.stderr = RubyTerraform.configuration.logger
  end

  def write_output(content, success)
    # write the output of terraform apply
    # in STDOUT and file
    File.open(
      Rails.configuration.x.terraform_log_filename, 'a'
    ) { |file| file.write(content) }
    if success
      logger.info content
    else
      logger.error content
    end
  end

  def update_terraform_progress(content, error)
    progress = {}
    created_resources = content.scan(/Creation complete after/).size
    text = if created_resources == @@planned_resources
      t('deploy.finished')
    else
      t('deploy.creating')
    end
    progress['infra-bar'] = {
      progress: created_resources * 100 / @@planned_resources,
      text:     text,
      success:  error.nil? ? true : false
    }
    return progress
  end
end
