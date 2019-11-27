# frozen_string_literal: true

# common module for handling terraform exports
module Exportable
  def export_into(path, filename=self.filename)
    File.write(File.join(path, filename), content)
  end

  def export
    export_into(Rails.configuration.x.source_export_dir)
  end
end
