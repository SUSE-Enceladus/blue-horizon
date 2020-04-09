# frozen_string_literal: true

require 'ruby_terraform'
# Imported content from terraform sources into an editable format
class Source < ApplicationRecord
  include Exportable

  before_validation :no_path_in_filename
  validates :filename, uniqueness: true
  validate :terraform_validation

  scope :terraform, -> { where('filename LIKE ?', '%.tf') }
  scope :variables, -> { where('filename LIKE ?', 'variable%.tf.json') }

  def no_path_in_filename
    self.filename = filename.split('/').last
  end

  def terraform_validation
    Terraform.new.validate(true, false)
  end
end
