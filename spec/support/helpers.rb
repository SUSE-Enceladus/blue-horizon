# frozen_string_literal: true

require 'ruby_terraform'

module Helpers
  def populate_sources(auth_plan: false, include_mocks: true)
    sources_dir =
      if auth_plan
        'sources_auth'
      else
        'sources'
      end
    source_path = Rails.root.join('spec', 'fixtures', sources_dir)
    Dir.glob(source_path.join('**/*')).each do |filepath|
      next if !include_mocks && filepath.include?('mocks')

      relative_path = filepath.to_s.sub("#{source_path}/", '')
      Source.import(source_path, relative_path, validate: false)
    end
    Source.all
  end

  def terraform_apply(auth_plan: false, include_mocks: true)
    populate_sources(auth_plan: auth_plan, include_mocks: include_mocks)
    yield if block_given?
    Source.all.each(&:export)
    terraform = Terraform.new
    terraform.apply({
                      directory:    Rails.configuration.x.source_export_dir,
                      auto_approve: true,
                      no_color:     true
                    }
                   )
    return terraform
  end

  def authorize!
    allow_any_instance_of(AuthorizationHelper)
      .to receive(:check_and_alert).and_return(true)
    allow_any_instance_of(AuthorizationHelper)
      .to receive(:can).and_return(true)
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
    plan = File.read(Rails.root.join('spec', 'fixtures', 'current_plan.json'))
    terraform_version = `terraform --version`.match(/v([0-9.]+)/)[1]
    plan.gsub('$VERSION', terraform_version)
  end

  def nested_plan_fixture_json
    File.read(Rails.root.join('spec', 'fixtures', 'nested_plan.json'))
  end

  def deploy_output
    File.read(Rails.root.join('spec', 'fixtures', 'deploy.txt'))
  end

  def metadata_fixture(name)
    File.read(Rails.root.join('spec', 'fixtures', 'metadata', name))
  end

  def collect_variable_names
    source_path =
      Rails.root.join('spec', 'fixtures', 'sources', 'variable*.tf.json')
    Dir.glob(source_path).collect do |variables_source|
      JSON.parse(File.read(variables_source))['variable'].keys
    end.flatten
  end

  def set_export_path
    Rails.configuration.x.source_export_dir = Rails.root.join('tmp', 'test-run')
  end

  def cleanup_export_path
    FileUtils.rm_rf(Rails.configuration.x.source_export_dir)
  end

  def make_export_path
    FileUtils.mkdir_p(Rails.configuration.x.source_export_dir)
  end

  def working_path
    Rails.configuration.x.source_export_dir
  end

  def mock_metadata_location(location)
    allow_any_instance_of(Metadata).to receive(:location).and_return(location)
  end
end

RSpec.configure do |config|
  config.include Helpers

  config.before do
    set_export_path
    cleanup_export_path
    make_export_path
  end
end
