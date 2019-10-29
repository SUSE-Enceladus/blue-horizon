Rails.application.configure do
  # Export path for modified source files (where terraform will run)
  # defaults to tmp/terraform
  # config.x.source_export_dir = Rails.root.join('tmp', 'terraform')
end

require 'fileutils'

if Rails.configuration.x.source_export_dir.blank?
  Rails.configuration.x.source_export_dir = Rails.root.join('tmp', 'terraform')
end
FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)
