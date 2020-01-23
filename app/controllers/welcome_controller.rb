# frozen_string_literal: true

class WelcomeController < ApplicationController
  include Defaults

  def index; end

  def advanced
    Rails.configuration.x.advanced_mode = true
    redirect_to sources_path
  end

  def simple
    Rails.configuration.x.advanced_mode = false
    redirect_to cluster_path
  end

  def download
    files
    zip_files
    send_data @compressed_filestream.read, filename: 'cap_scripts.zip'
  end

  def files
    prefix = Rails.configuration.x.source_export_dir
    sources = Source.all.order(:filename)
    @files = sources.map { |source| prefix + source.filename }

    @files.push Pathname.new(log_path_filename) if
      File.exist?(log_path_filename)
  end

  def zip_files
    @compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      @files.each do |file|
        zos.put_next_entry File.basename(file)
        zos.print file.read
      end
    end

    @compressed_filestream.rewind
  end
end
