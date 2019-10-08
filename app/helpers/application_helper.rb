module ApplicationHelper
  def sidebar_icons
    {
      welcome: 'announcement',
      cluster: 'photo_size_select_small',
      framework: 'playlist_add',
      advanced: 'configuration_file',
      plan: 'organization',
      deploy: 'play_arrow',
      download: 'file_download'
    }
  end

  def sidebar_menu_item(path_key, active=false)
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
end
