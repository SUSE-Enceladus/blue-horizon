# frozen_string_literal: true

require 'ruby_terraform'
# Imported content from terraform sources into an editable format
class Source < ApplicationRecord
  include Exportable

  validates :filename, uniqueness: true
  validate :terraform_validation

  scope :terraform, -> { where('filename LIKE ?', '%.tf') }
  scope :variables, -> { where('filename LIKE ?', 'variable%.tf.json') }

  def self.import(source_dir, filename, save_options={})
    source = new(
      filename: filename,
      content:  File.read(File.join(source_dir, filename))
    )
    source.save(save_options)
    return source
  end

  def self.extensions
    Rails.configuration.x.supported_source_extensions
  end

  def self.import_dir(source_dir, save_options={})
    glob = "**/*{#{extensions.join(',')}}"
    Dir.glob(File.join(source_dir, glob)).collect do |filename|
      relative_path = filename.to_s.sub("#{source_dir}/", '')
      import(source_dir, relative_path, save_options)
    end
  end

  def terraform_validation
    Terraform.new.validate(true)
  end
end
