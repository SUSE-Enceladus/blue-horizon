module ApplicationHelper
  def sidebar_icons
    {
      'Welcome'         => 'announcement',
      'Cluster size'    => 'photo_size_select_small',
      'Additional data' => 'playlist_add',
      'Custom/Advanced' => 'details',
      'Plan'            => 'organization',
      'Deploy'          => 'play_arrow',
      'Download'        => 'file_download'
    }
  end

  def sidebar_menu_item(text, icon, active=false)
    content_tag(:a,
      class: ['list-group-item', (active ? 'active' : '')],
      data:  { toggle: 'tooltip', placement: 'right', original_title: text }
    ) do
      content_tag(:i, icon, class: ['eos-icons', 'md-18']) +
      ' ' +
      content_tag(:span, text, class: 'collapse')
    end
  end
end
