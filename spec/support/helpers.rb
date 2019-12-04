# frozen_string_literal: true

require 'ruby_terraform'

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

  def stubbed_ruby_terraform_config
    double_allowing(:binary=, :logger=, :logger, :stdout=, :stderr=)
  end

  def double_allowing(*messages)
    instance = double
    messages.each do |message|
      allow(instance).to(receive(message))
    end
    instance
  end
end

RSpec.configure do |config|
  config.include Helpers
end
