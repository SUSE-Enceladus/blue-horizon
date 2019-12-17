# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DeploysController, type: :controller do
  context 'when deploying terraform plan' do
    let(:ruby_terraform) { RubyTerraform }
    let(:variable_instance) { Variable.new('') }
    let(:random_path) do
      Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    end

    let(:sources_dir) { Rails.root.join('tmp', 'terraform') }
    let(:terraform_tfvars) { 'terraform.tfvars' }

    before do
      FileUtils.mkdir_p(random_path)
    end

    after do
      FileUtils.rm_rf(random_path)
    end

    it 'deploys a plan' do
      allow(File).to receive(:exist?).and_return(true)
      allow(File).to receive(:read)
      allow(JSON).to receive(:parse).and_return(foo: 'bar')
      allow(ruby_terraform).to receive(:apply)

      get :show

      expect(ruby_terraform).to(
        have_received(:apply)
          .with(
            directory: sources_dir, vars: { foo: 'bar' },
            vars_files: [terraform_tfvars],
            auto_approve: true
          )
      )
    end
  end
end
