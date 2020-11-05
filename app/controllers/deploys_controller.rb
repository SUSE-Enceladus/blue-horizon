# frozen_string_literal: true

require 'ruby_terraform'

class DeploysController < ApplicationController

  class_attribute :planned_resources

  def update
    logger.info('Calling run_deploy')
    @apply_args = {
      directory:    Rails.configuration.x.source_export_dir,
      auto_approve: true,
      no_color:     true
    }
    DeploysController.planned_resources = get_planned_resources().count()
    Terraform.new.apply(@apply_args)
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

    complete_count = content.scan(/Creation complete after/).size
    progress = {
      'infra-bar': {
        progress: complete_count*100/DeploysController.planned_resources,
        success:  error.nil? ? true : false
      }
    }

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

  def get_planned_resources
    resources = []
    Terraform.new.show
    show_output = Terraform.stdout.string
    show_output = JSON.parse(show_output)
    show_output['planned_values'].each { |key, value|
      if key == 'root_module'
        resources |= value['resources']
        if value.key? 'child_modules'
          resources |= get_child_resources(value['child_modules'])
        end
      end
    }
    resources
  end

  def get_child_resources(child_resources)
    resources = []
    child_resources.each { |value|
      if value.key? 'resources'
        resources |= value['resources'].filter_map {|resource| resource if resource['mode'] == 'managed'}

      end
      if value.key? 'child_modules'
        resources |= get_child_resources(value['child_modules'])
      end
    }
    resources
  end
end
