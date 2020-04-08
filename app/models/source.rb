# frozen_string_literal: true

require 'ruby_terraform'
# Imported content from terraform sources into an editable format
class Source < ApplicationRecord
  include Exportable

  validates :filename, uniqueness: true
  before_validation :no_path_in_filename
  after_save :validate_scripts

  scope :terraform, -> { where('filename LIKE ?', '%.tf') }
  scope :variables, -> { where('filename LIKE ?', 'variable%.tf.json') }

  def no_path_in_filename
    self.filename = filename.split('/').last
  end

  def validate_scripts
    terra = Terraform.new
    terra.validate(true, false)
  end
end
