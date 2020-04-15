# frozen_string_literal: true

require 'ruby_terraform'

module Helpers
  def populate_sources(auth_plan=false, include_mocks=true)
    sources_dir =
      if auth_plan
        'sources_auth'
      else
        'sources'
      end
    source_path = Rails.root.join('spec', 'fixtures', sources_dir, '*')
    Dir.glob(source_path).each do |filepath|
      next if !include_mocks && filepath.include?('mocks')

      Source.new(
        filename: filepath.split('/').last,
        content:  File.read(filepath)
      ).save(validate: false)
    end
    Source.all
  end

  def current_plan_fixture
    # place the binary plan file
    source_path =
      Rails.root.join('spec', 'fixtures', 'current_plan')
    dest_path =
      Rails.configuration.x.source_export_dir.join('current_plan')
    FileUtils.cp source_path, dest_path

    current_plan_fixture_json
  end

  def current_plan_fixture_json
    File.read(Rails.root.join('spec', 'fixtures', 'current_plan.json'))
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
