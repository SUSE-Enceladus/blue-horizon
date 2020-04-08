# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DownloadController, type: :controller do
  let(:ruby_terraform) { RubyTerraform }
  let(:random_path) { random_export_path }
  let!(:sources) do
    allow(ruby_terraform).to receive(:init)
    allow(ruby_terraform).to receive(:validate)
    FileUtils.mkdir_p(random_path)

    populate_sources
  end

  context 'when getting and sending files' do
    before do
      mock_member = double
      allow(mock_member).to receive(:read)
      controller.instance_variable_set(:@compressed_filestream, mock_member)
      allow(controller).to receive(:zip_files)
      allow(controller).to receive(:send_data)

      Variable.load.export
      Source.all.each(&:export)
    end

    after do
      FileUtils.rm_rf(random_path)
    end

    it 'send zip data' do
      allow(controller).to receive(:files)

      get :download, format: :zip

      zip_name = controller.instance_variable_get(:@zip_name)
      expect(controller).to(
        have_received(:send_data)
          .with(nil, filename: zip_name)
      )
      index = zip_name.index('-') - 1
      zip_name = zip_name[0..index]
      expect(zip_name).to eq('terraform_scripts_and_log')
    end

    it 'gets source files' do
      expected_files = sources.pluck(:filename)
      prefix = Rails.configuration.x.source_export_dir
      log_filename = Rails.configuration.x.terraform_log_filename

      expected_files.map! do |expected_file|
        Pathname.new(prefix + expected_file)
      end
      expected_files.push Pathname.new(log_filename) if
        File.exist?(log_filename)

      get :download, format: :zip

      files = controller.instance_variable_get(:@files)
      expected_files.each do |expected_file|
        expect(files).to be_include(expected_file)
      end
    end

    it 'gets files without extensions' do
      test_file = random_path.join('test_file')
      File.write(test_file, 'w') { |_f| '' }

      get :download, format: :zip
      files = controller.instance_variable_get(:@files)
      expect(files).to be_include(test_file)
    end
  end

  context 'when creating zip files' do
    it 'zip files' do
      prefix = Rails.root.join('spec', 'fixtures', 'sources')
      controller.instance_variable_set(
        :@files,
        sources.map { |source| Pathname.new(prefix + source.filename) }
      )
      allow(controller).to receive(:files)
      allow(controller).to receive(:send_data)

      get :download, format: :zip

      expect(controller.instance_variable_get(:@compressed_filestream)).to(
        be_a(StringIO)
      )
      expect(controller.instance_variable_get(:@compressed_filestream).length)
        .to be > 0
    end
  end
end
