# frozen_string_literal: true

# General view helpers
module ApplicationHelper
  def sidebar_icons
    {
      welcome:   'announcement',
      sources:   'configuration_file',
      cluster:   'photo_size_select_small',
      variables: 'playlist_add',
      plan:      'organization',
      deploy:    'play_arrow',
      download:  'file_download'
    }
  end

  def simple_sidebar_menu_items
    [
      :welcome,
      :cluster,
      :variables,
      :plan,
      :deploy,
      :download
    ]
  end

  def advanced_sidebar_menu_items
    [
      :welcome,
      :sources,
      :plan,
      :deploy,
      :download
    ]
  end

  def sidebar_menu_items(advanced=Rails.configuration.x.advanced_mode)
    if advanced
      advanced_sidebar_menu_items
    else
      simple_sidebar_menu_items
    end
  end

  def sidebar_menu_item(path_key)
    text = t("sidebar.#{path_key}")
    icon = sidebar_icons[path_key]
    url = "/#{path_key}"

    content = [
      content_tag(:i, icon, class: ['eos-icons', 'md-18']),
      content_tag(:span, text, class: 'collapse')
    ].join(' ').html_safe

    active_link_to(content, url,
      class: 'list-group-item',
      data:  { toggle: 'tooltip', placement: 'right', original_title: text }
    )
  end

  def bootstrap_flash
    flash.collect do |type, message|
      # Skip empty messages
      next if message.blank?

      context = case type.to_sym
      when :notice
        :success
      when :alert
        :warning
      when :error
        :danger
      else
        :secondary
      end
      render 'layouts/flash', context: context, message: message
    end.join.html_safe
  end
end
