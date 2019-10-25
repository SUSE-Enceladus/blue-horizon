require 'rails_helper'

RSpec.describe Source, type: :model do
  it 'has unique filenames' do
    static_filename = 'static'
    create(:source, filename: static_filename)
    expect {
      create(:source, filename: static_filename)
    }.to raise_error(ActiveRecord::RecordInvalid)
  end

  it 'stores the filename without any path' do
    dir = Faker::File.dir
    filename = Faker::File.file_name(dir: dir)
    source = create(:source, filename: filename)
    expect(source.filename).not_to include(dir)
  end
end
