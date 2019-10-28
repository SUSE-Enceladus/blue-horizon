# Populate editable sources from the static documents

Dir.glob(Rails.root.join('vendor', 'sources', '*')).each do |filepath|
  filename = filepath.split('/').last
  unless Source.find_by_filename(filename)
    Source.create(
      filename: filename,
      content:  File.read(filepath)
    )
  end
end