# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database
# with its default values.
# The data can then be loaded with the rails db:seed command
# (or created alongside the database with db:setup).

Rails.logger = Logger.new(STDOUT)
Rails.logger.level = Logger::INFO

# Populate KeyValues
if ENV['CLOUD_FRAMEWORK'].present?
  KeyValue.set(:cloud_framework, ENV['CLOUD_FRAMEWORK'])
end

# Populate editable sources from the static documents
def import_sources(glob)
  glob.each do |filepath|
    filename = filepath.split('/').last
    next if Source.find_by(filename: filename)

    Rails.logger.info("New source file '#{filename}'")
    Source.create(
      filename: filename,
      content:  File.read(filepath)
    )
  end
end

sources_path = ENV['TERRAFORM_SOURCES_PATH']
sources_path ||= Rails.root.join('vendor', 'sources')
Rails.configuration.x.supported_source_extensions.keys.each do |ext|
  import_sources(Dir.glob(File.join(sources_path, "*#{ext}")))
end
