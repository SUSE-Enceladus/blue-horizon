# frozen_string_literal: true

require 'rails_helper'

RSpec.describe WelcomeController, type: :controller do
  include Defaults

  context 'when getting and sending files' do
    let!(:sources) { populate_sources }

    before do
      mock_member = double
      allow(mock_member).to receive(:read)
      controller.instance_variable_set(:@compressed_filestream, mock_member)
      allow(controller).to receive(:zip_files)
      allow(controller).to receive(:send_data)
    end

    it 'send zip data' do
      allow(controller).to receive(:files)

      get :download, format: :zip

      expect(controller).to(
        have_received(:send_data)
          .with(nil, filename: 'cap_scripts.zip')
      )
    end

    it 'gets CAP files' do
      expected_files = sources.pluck(:filename)
      prefix = Rails.configuration.x.source_export_dir

      expected_files.map! do |expected_file|
        Pathname.new(prefix + expected_file)
      end
      expected_files.push Pathname.new(log_path_filename)

      get :download, format: :zip

      expect(controller.instance_variable_get(:@files)).to(
        eq(expected_files)
      )
    end
  end

  context 'when creating zip files' do
    let!(:sources) { populate_sources }

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
