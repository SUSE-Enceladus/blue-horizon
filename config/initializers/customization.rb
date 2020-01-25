# frozen_string_literal: true

Rails.application.configure do
  custom_config_path = ENV['BLUE_HORIZON_CUSTOMIZER']
  custom_config_path ||= Rails.root.join('vendor', 'customization.yml')

  if File.exist? custom_config_path
    customizer = YAML.load_file(custom_config_path)
    config.x.merge(customizer)
  end

  # Customizations

  # Export path for modified source files (where terraform will run)
  # In customization.yml:
  # source_export_dir: /path/to/working/dir
  # defaults to tmp/terraform
end

# The following performs required actions based on custom configuration above
# PLEASE DO NOT EDIT BELOW THIS LINE

require 'fileutils'

if Rails.configuration.x.source_export_dir.blank?
  Rails.configuration.x.source_export_dir = Rails.root.join('tmp', 'terraform')
end
FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)
Rails.configuration.x.terraform_log_filename = Rails.configuration.x.source_export_dir + 'ruby-terraform.log'
