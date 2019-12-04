# frozen_string_literal: true

Rails.application.configure do
  # Export path for modified source files (where terraform will run)
  # defaults to tmp/terraform
  # config.x.source_export_dir = Rails.root.join('tmp', 'terraform')

  # Default application mode: simple or advanced?
  # default is false (simple)
  # Rails.configuration.x.advanced_mode = false
end

# The following performs required actions based on custom configuration above
# PLEASE DO NOT EDIT BELOW THIS LINE

require 'fileutils'

if Rails.configuration.x.source_export_dir.blank?
  Rails.configuration.x.source_export_dir = Rails.root.join('tmp', 'terraform')
end
FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)

if Rails.configuration.x.advanced_mode.blank?
  Rails.configuration.x.advanced_mode = false
end
