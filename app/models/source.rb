class Source < ApplicationRecord
  validates_uniqueness_of :filename
  before_validation :no_path_in_filename

  def no_path_in_filename()
    self.filename = self.filename.split('/').last
  end

  def export_into(path)
    File.write(File.join(path, self.filename), self.content)
  end

  def export()
    self.export_into(Rails.configuration.x.source_export_dir)
  end
end
