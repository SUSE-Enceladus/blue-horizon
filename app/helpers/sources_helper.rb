# frozen_string_literal: true

# Helpers specific to editing sources
module SourcesHelper
  def ace_highlighter_for(filename)
    mode =
      case File.extname(filename)
      when '.sh'
        'sh'
      else
        'terraform'
      end
    return "ace/mode/#{mode}"
  end
end
