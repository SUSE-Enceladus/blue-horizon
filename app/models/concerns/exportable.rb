# frozen_string_literal: true

# common module for handling terraform exports
module Exportable
  EXECUTABLE = ['.sh'].freeze

  def export_into(path, filename=self.filename)
    File.write(File.join(path, filename), content)
    return unless EXECUTABLE.include?(File.extname(filename))

    FileUtils.chmod('+x', File.join(path, filename))
  end

  def export
    export_into(Rails.configuration.x.source_export_dir)
  end
end
