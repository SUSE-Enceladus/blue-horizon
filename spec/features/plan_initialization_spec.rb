# frozen_string_literal: true

require 'rails_helper'

describe 'plan initialization' do

  context 'when configuring terraform' do
    let(:log_filename) { 'ruby-terraform-test.log' }
    let(:random_path) do
      Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    end

    let(:expected_random_log_path) do
      File.join(random_path, log_filename)
    end

    before do
      FileUtils.mkdir_p(random_path)
      log_file = File.open(expected_random_log_path, 'a')
      RubyTerraform.configure do |config|
        config.binary = 'path to binary'
        config.logger = Logger.new(
          RubyTerraform::MultiIO.new(STDOUT, log_file),
          level: :debug
        )
      end
    end

    after do
      FileUtils.rm_rf(random_path)
    end

    it 'sets the configuration' do
      config = stubbed_ruby_terraform_config
      allow_any_instance_of(PlansController).to receive(:init_terraform)
      expect(RubyTerraform).to receive(:configure).and_yield(config)
      expect(File).to exist(expected_random_log_path)
      visit('/plan')
    end

    it 'initialize terraform' do
      allow_any_instance_of(PlansController).to receive(:config_terraform)
      expect(RubyTerraform).to receive(:init)
      visit('/plan')
    end
  end
end
