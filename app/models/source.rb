# frozen_string_literal: true

# Imported content from terraform sources into an editable format
class Source < ApplicationRecord
  include Exportable

  validates :filename, uniqueness: true
  before_validation :no_path_in_filename

  scope :terraform, -> { where('filename LIKE ?', '%.tf') }

  def no_path_in_filename
    self.filename = filename.split('/').last
  end
end
