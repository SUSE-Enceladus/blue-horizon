module Helpers
  def populate_sources
    Dir.glob(Rails.root.join('spec', 'fixtures', 'sources', '*')).each do |filepath|
      Source.create(
        filename: filepath,
        content:  File.read(filepath)
      )
    end
    Source.all
  end

  def collect_variable_names
    HCL::Checker.parse(
      File.read(Rails.root.join('spec', 'fixtures', 'sources', 'variables.tf'))
    )['variable'].keys
  end
end

RSpec.configure do |config|
  config.include Helpers
end
