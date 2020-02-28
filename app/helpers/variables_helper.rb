# frozen_string_literal: true

# View helpers for working with variables
module VariablesHelper
  def required
    content_tag(
      :span,
      '*',
      title: t(:required),
      data:  { toggle: 'tooltip' }
    )
  end

  def string_input_type(description)
    if description.to_s.downcase.include?(t('password_key'))
      'password'
    else
      'text'
    end
  end
end
