# frozen_string_literal: true

# Imported content from terraform sources into an editable format
class Source < ApplicationRecord
  validates :filename, uniqueness: true
  before_validation :no_path_in_filename

  scope :terraform, -> { where('filename LIKE ?', '%.tf') }

  def no_path_in_filename
    self.filename = filename.split('/').last
  end

  def export_into(path)
    File.write(File.join(path, filename), content)
  end

  def export
    export_into(Rails.configuration.x.source_export_dir)
  end
end
