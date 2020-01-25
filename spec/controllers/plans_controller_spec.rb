# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansController, type: :controller do
  let(:json_instance) { JSON }

  let(:sources_dir) { Rails.root.join('tmp', 'terraform') }

  context 'when preparing terraform' do
    let(:variable_instance) { Variable.new('') }
    let(:variables) { Variable.load }
    let(:log_filename) { 'ruby-terraform-test.log' }
    let(:random_path) do
      Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    end

    let(:expected_random_log_path) do
      File.join(random_path, log_filename)
    end

    let(:ruby_terraform) { RubyTerraform }

    let(:log_file) { Logger::LogDevice.new(expected_random_log_path) }

    before do
      Rails.configuration.x.terraform_log_filename = expected_random_log_path
      allow(controller).to receive(:terraform_plan)
      allow(controller).to receive(:terraform_show)

      FileUtils.mkdir_p(random_path)
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
      allow(controller).to receive(:init_terraform)
      allow(controller).to receive(:read_exported_vars)

      get :show

      ruby_terraform.configure do |config|
        config.logger do |log_device|
          expect(log_device.targets).to eq([IO::STDOUT, log_file])
        end
      end
      expect(File).to exist(expected_random_log_path)
    end

    it 'initializes terraform' do
      allow(ruby_terraform).to receive(:init)
      allow(controller).to receive(:config_terraform)
      allow(controller).to receive(:read_exported_vars)

      get :show

      expect(ruby_terraform).to(
        have_received(:init)
          .with(
            from_module: '', path: sources_dir
          )
      )
    end

    it 'exports variables' do
      allow(variable_instance).to receive(:load)
      allow(controller).to receive(:config_terraform)
      allow(controller).to receive(:init_terraform)
      allow(controller).to receive(:read_exported_sources)
      allow(json_instance).to receive(:parse)

      get :show

      expect(json_instance).to have_received(:parse)
    end
  end

  context 'when not exporting' do
    before do
      allow(File).to receive(:exist?).and_return(false)
      allow(controller).to receive(:terraform_plan)
      allow(controller).to receive(:terraform_show)
      allow(controller).to receive(:config_terraform)
      allow(controller).to receive(:init_terraform)
      allow(json_instance).to receive(:parse)
      allow(controller).to receive(:read_exported_sources)
    end

    it 'no exported variables' do
      get :show

      expect(flash[:error]).to match(/There are no vars saved./)
    end
  end

  context 'when showing the plan' do
    let(:ruby_terraform) { RubyTerraform }
    let(:file) { File }
    let(:file_write) { File }
    let(:plan_file) { Rails.root.join(sources_dir, 'current_plan') }

    before do
      allow(controller).to receive(:config_terraform)
      allow(controller).to receive(:init_terraform)
      allow(controller).to receive(:read_exported_sources)
    end

    it 'runs terraform plan' do
      allow(controller).to receive(:terraform_show)
      allow(ruby_terraform).to receive(:plan)

      get :show

      expect(ruby_terraform).to(
        have_received(:plan)
          .with(
            directory: sources_dir, vars: {},
            plan: plan_file
          )
      )
    end

    it 'runs terraform show' do
      allow(controller).to receive(:terraform_plan)
      allow(ruby_terraform).to receive(:show)
      allow(file).to receive(:open).and_return(File)
      allow(file_write).to receive(:write)

      get :show

      expect(ruby_terraform).to(
        have_received(:show)
          .with(
            json: true, path: plan_file
          )
      )
    end

    it 'handles rubyterraform exception' do
      allow(ruby_terraform).to receive(:show)
      allow(file).to receive(:open).and_return(File)
      allow(file_write).to receive(:write)
      allow(ruby_terraform).to(
        receive(:plan)
          .and_raise(RubyTerraform::Errors::ExecutionError)
      )

      get :show

      expect(flash[:error]).to match(/Plan operation has failed/)
    end
  end
end
