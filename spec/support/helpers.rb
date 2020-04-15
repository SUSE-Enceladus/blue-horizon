# frozen_string_literal: true

require 'ruby_terraform'

module Helpers
  def populate_sources(auth_plan=nil)
    sources_dir =
      if auth_plan
        'sources_auth'
      else
        'sources'
      end
    source_path = Rails.root.join('spec', 'fixtures', sources_dir, '*')
    Dir.glob(source_path).each do |filepath|
      Source.create(
        filename: filepath,
        content:  File.read(filepath)
      )
    end
    Source.all
  end

  def collect_variable_names
    source_path =
      Rails.root.join('spec', 'fixtures', 'sources', 'variable*.tf.json')
    Dir.glob(source_path).collect do |variables_source|
      JSON.parse(File.read(variables_source))['variable'].keys
    end.flatten
  end

  def random_export_path
    random_path = Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    Rails.configuration.x.source_export_dir = random_path
  end
end

RSpec.configure do |config|
  config.include Helpers
end
