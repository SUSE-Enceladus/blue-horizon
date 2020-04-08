# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeploysController, type: :controller do
  render_views

  context 'when deploying terraform plan' do
    let(:ruby_terraform) { RubyTerraform }
    let(:terra_stderr) { ruby_terraform.configuration.stderr }
    let(:variable_instance) { Variable.new('') }
    let(:random_path) do
      Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    end

    let(:sources_dir) { Rails.root.join('tmp', 'terraform') }
    let(:terraform_tfvars) { 'terraform.tfvars' }
    let(:file) { File }

    before do
      FileUtils.mkdir_p(random_path)
      allow(Terraform).to(
        receive(:statefilename)
          .and_return(random_path.join('terraform.tfstate'))
      )
    end

    after do
      FileUtils.rm_rf(random_path)
    end

    it 'deploys a plan successfully' do
      allow(controller).to receive(:close_log_info)
      allow(ruby_terraform).to receive(:apply)

      get :update, format: :json

      expect(ruby_terraform).to(
        have_received(:apply)
          .with(
            directory:    sources_dir,
            auto_approve: true,
            no_color:     true
          )
      )
    end

    it 'raise exception when deploying a plan' do
      allow(File).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:rm)
      allow(ruby_terraform).to(
        receive(:apply)
          .and_raise(RubyTerraform::Errors::ExecutionError)
      )

      get :update, format: :json
    end

    it 'can show deploy output' do
      filename = Rails.configuration.x.terraform_log_filename
      allow(File).to receive(:open).with(filename, 'a').and_return(file)
      allow(file).to receive(:write).with("hello world! Apply complete!\n")
      string_output = StringIO.new
      string_output.puts 'hello world! Apply complete!'

      RubyTerraform.configure do |config|
        config.stdout = string_output
      end

      expected_html = "<code id='output'>hello world! " \
                      "Apply complete!</code>\n<i class=" \
                      "'eos-icon-loading md-48 centered hide'></i>\n"
      expected_json = {
        new_html: expected_html,
        success:  true,
        error:    nil,
        next:     '/wrapup'
      }
      allow(controller).to receive(:render).with(json: expected_json)
      allow(ruby_terraform).to receive(:apply)

      get :send_current_status, format: :json

      expect(response).to be_success
    end

    it 'can show error output when deploy fails' do
      allow(File).to receive(:exist?).and_return(true)
      allow(FileUtils).to receive(:rm)
      allow(controller).to receive(:close_log_info)
      string_output = StringIO.new
      string_output.puts 'Error'

      RubyTerraform.configure do |config|
        config.stderr = string_output
      end

      expected_html = "<code id='output'></code>\n<i class=" \
                      "'eos-icon-loading md-48 centered hide'></i>\n"
      expected_json = { new_html: expected_html, success: false,
                        error: "Error\n", next: '/wrapup' }

      allow(controller).to receive(:render).with(json: expected_json)

      get :send_current_status, format: :json

      expect(response).to be_success
    end
  end
end
