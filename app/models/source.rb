# frozen_string_literal: true

class Source < ApplicationRecord
  validates :filename, uniqueness: true
  before_validation :no_path_in_filename

  scope :terraform, -> { where('filename LIKE ?', '%.tf') }

  def no_path_in_filename
    self.filename = self.filename.split('/').last
  end

  def export_into(path)
    File.write(File.join(path, self.filename), self.content)
  end

  def export
    self.export_into(Rails.configuration.x.source_export_dir)
  end
end
