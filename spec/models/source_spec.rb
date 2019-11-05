require 'rails_helper'
require 'fileutils'

RSpec.describe Source, type: :model do
  it 'has unique filenames' do
    static_filename = 'static'
    create(:source, filename: static_filename)
    expect do
      create(:source, filename: static_filename)
    end.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'stores the filename without any path' do
    dir = Faker::File.dir
    filename = Faker::File.file_name(dir: dir)
    source = create(:source, filename: filename)
    expect(source.filename).not_to include(dir)
  end

  context 'exporting' do
    let(:random_path) do
      Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
    end

    before :each do
      Rails.configuration.x.source_export_dir = random_path
      FileUtils.mkdir_p(random_path)
    end

    after :each do
      FileUtils.rm_rf(random_path)
    end

    it 'writes to a file' do
      source = create(:source)
      source.export_into(random_path)
      expected_export_path = File.join(random_path, source.filename)
      expect(File.exist?(expected_export_path)).to be_truthy
      file_content = File.read(expected_export_path)
      expect(file_content).to eq(source.content)
    end

    it 'writes to the config path unless otherwise specified' do
      source = create(:source)
      source.export
      expected_export_path = File.join(Rails.configuration.x.source_export_dir, source.filename)
      expect(File.exist?(expected_export_path)).to be_truthy
    end
  end
end
