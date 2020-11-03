# frozen_string_literal: true

Rails.application.configure do
  # file types supported as sources,
  # and the ace editor highlighter for each file type
  config.x.supported_source_extensions = [
    '.json',
    '.sh',
    '.tf',
    '.tmpl',
    '.yaml',
    '.yml'
  ]
end
