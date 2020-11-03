# frozen_string_literal: true

# View helpers for working with variables
module VariablesHelper
  def required
    tag.span('*', title: t(:required),
                  data:  { toggle: 'tooltip' }
    )
  end

  def formatted_description(description)
    return nil unless description

    tag.small(
      markdown(description, escape_html: false),
      class: ['form-text', 'text-muted']
    )
  end

  def options_regex
    /#{t('options_key')}=\[(?<options>.*?)\]/i
  end

  def string_input_type(key, description)
    description ||= ''

    if description.match?(options_regex)
      'select'
    elsif description.match?(/#{t('password_key')}/i)
      'password'
    elsif key.match?(Variable.file_regex)
      'file'
    else
      'text'
    end
  end

  def get_select_options(description)
    description.match(options_regex)[:options].split(',')
  rescue StandardError
    []
  end
end
