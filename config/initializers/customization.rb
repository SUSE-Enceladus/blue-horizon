# frozen_string_literal: true

Rails.application.configure do
  # Customization

  # Start with a config file
  custom_config_path = ENV['BLUE_HORIZON_CUSTOMIZER']
  custom_config_path ||= Rails.root.join('vendor', 'customization.json')

  config.x = if File.exist? custom_config_path
    JSON.parse(IO.read(custom_config_path), object_class: OpenStruct)
  else
    OpenStruct.new
  end

  # Export path for modified source files (where terraform will run)
  config.x.source_export_dir ||= Rails.root.join('tmp', 'terraform')

  # Terraform log path
  config.x.terraform_log_filename ||= config.x.source_export_dir.join('ruby-terraform.log')

  # cluster sizing
  config.x.cluster_size ||= OpenStruct.new
  config.x.cluster_size.min ||= 3
  config.x.cluster_size.max ||= 250
end

# The following performs required actions based on custom configuration above

require 'fileutils'

FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)
