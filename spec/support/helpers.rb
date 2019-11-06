# frozen_string_literal: true

module Helpers
  def populate_sources
    source_path = Rails.root.join('spec', 'fixtures', 'sources', '*')
    Dir.glob(source_path).each do |filepath|
      Source.create(
        filename: filepath,
        content:  File.read(filepath)
      )
    end
    Source.all
  end

  def collect_variable_names
    variables_source =
      Rails.root.join('spec', 'fixtures', 'sources', 'variables.tf')
    HCL::Checker.parse(File.read(variables_source))['variable'].keys
  end
end

RSpec.configure do |config|
  config.include Helpers
end
