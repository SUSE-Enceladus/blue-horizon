# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PlansController, type: :controller do
  let(:json_instance) { JSON }
  let!(:random_path) { random_export_path }

  before do
    FileUtils.mkdir_p(random_path)
  end

  after do
    FileUtils.rm_rf(random_path)
  end

  context 'when preparing terraform' do
    let(:variable_instance) { Variable.new('{}') }
    let(:variables) { Variable.load }
    let(:log_filename) { 'ruby-terraform-test.log' }
    let(:expected_random_log_path) do
      File.join(random_path, log_filename)
    end

    let(:ruby_terraform) { RubyTerraform }

    let(:log_file) { Logger::LogDevice.new(expected_random_log_path) }

    before do
      Rails.configuration.x.terraform_log_filename = expected_random_log_path
      allow(controller).to receive(:terraform_plan)
      allow(controller).to receive(:terraform_show)

      RubyTerraform.configure do |config|
        config.binary = 'path to binary'
        config.logger = Logger.new(
          RubyTerraform::MultiIO.new(STDOUT, log_file),
          level: :debug
        )
      end
    end

    it 'sets the configuration' do
      allow(controller).to receive(:init_terraform)
      allow(controller).to receive(:read_exported_vars)

      put :update

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

      put :update

      expect(ruby_terraform).to(
        have_received(:init)
          .with(
            from_module: '', path: random_path
          )
      )
    end

    it 'exports variables' do
      allow(variable_instance).to receive(:load)
      allow(controller).to receive(:config_terraform)
      allow(controller).to receive(:init_terraform)
      allow(controller).to receive(:read_exported_sources)
      allow(json_instance).to receive(:parse)

      put :update

      expect(json_instance).to have_received(:parse).at_least(:once)
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
      put :update, format: :js

      expect(flash[:error]).to match(/There are no vars saved./)
    end
  end

  context 'when showing the plan' do
    let(:ruby_terraform) { RubyTerraform }
    let(:file) { File }
    let(:file_write) { File }
    let(:plan_file) { Rails.root.join(random_path, 'current_plan') }

    before do
      allow(controller).to receive(:config_terraform)
      allow(controller).to receive(:init_terraform)
      allow(controller).to receive(:read_exported_sources)
      allow(controller).to receive(:cleanup)
      allow(JSON).to receive(:pretty_generate)
      allow(JSON).to receive(:parse).and_return(blue: 'horizon')
    end

    it 'shows the saved plan' do
      allow(controller.helpers).to receive(:can).and_return(true)
      allow(ruby_terraform).to receive(:show)
      allow(controller).to(
        receive(:saved_plan_path)
          .and_return('super_plan')
      )

      get :show, format: :json

      expect(ruby_terraform).to(
        have_received(:show)
          .with(
            json: true, path: 'super_plan'
          )
      )
    end

    it 'allows to download the plan' do
      allow(controller.helpers).to receive(:can).and_return(true)
      allow(controller).to receive(:terraform_show)
      allow(ruby_terraform).to receive(:show)
      expected_content = 'attachment; filename="terraform_plan.json"'

      get :show, format: :json

      expect(response.header['Content-Disposition']).to eq(expected_content)
    end

    it 'does not show plan if no plan created' do
      allow(controller.helpers).to receive(:can).and_return(false)
      expected_content = 'text/html; charset=utf-8'

      get :show

      expect(response.header['Content-Type']).to eq(expected_content)
    end

    it 'runs terraform plan' do
      allow(controller).to receive(:terraform_show)
      allow(ruby_terraform).to receive(:plan)

      put :update, format: :js

      expect(ruby_terraform).to(
        have_received(:plan)
          .with(
            directory: random_path,
            plan:      plan_file
          )
      )
    end

    it 'runs terraform show after creating a plan' do
      allow(controller).to receive(:terraform_plan)
      allow(ruby_terraform).to receive(:show)

      put :update, format: :js

      expect(ruby_terraform).to(
        have_received(:show)
          .with(
            json: true, path: plan_file
          )
      )
    end

    it 'handles rubyterraform exception' do
      allow(ruby_terraform).to receive(:show)
      allow(ruby_terraform).to(
        receive(:plan)
          .and_raise(RubyTerraform::Errors::ExecutionError)
      )

      put :update, format: :js

      expect(flash[:error]).to match(/Plan operation has failed/)
    end
  end
end
