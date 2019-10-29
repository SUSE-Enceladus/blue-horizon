# Populate editable sources from the static documents
require 'fileutils'

Dir.glob(Rails.root.join('vendor', 'sources', '*')).each do |filepath|
  filename = filepath.split('/').last
  unless Source.find_by_filename(filename)
    Source.create(
      filename: filename,
      content:  File.read(filepath)
    )
  end
end

if Rails.configuration.x.source_export_dir.blank?
  Rails.configuration.x.source_export_dir = Rails.root.join('tmp', 'terraform')
end
FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)
