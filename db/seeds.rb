# frozen_string_literal: true

# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# Populate KeyValues
if ENV['CLOUD_FRAMEWORK'].present?
  KeyValue.set(:cloud_framework, ENV['CLOUD_FRAMEWORK'])
end

# Populate editable sources from the static documents
Dir.glob(Rails.root.join('vendor', 'sources', '*')).each do |filepath|
  filename = filepath.split('/').last
  next if Source.find_by(filename: filename)

  Source.create(
    filename: filename,
    content:  File.read(filepath)
  )
end
