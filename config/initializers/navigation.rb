# frozen_string_literal: true

# configure navigation
Rails.application.configure do
  # Start in simple mode by default
  config.x.advanced_mode = false

  # EOS icon names for each navigation path
  config.x.sidebar_icons = {
    welcome:   'announcement',
    sources:   'configuration_file',
    cluster:   'photo_size_select_small',
    variables: 'playlist_add',
    plan:      'organization',
    deploy:    'play_arrow',
    download:  'file_download'
  }

  # menus for each path
  config.x.simple_sidebar_menu_items = [
    :welcome,
    :cluster,
    :variables,
    :plan,
    :deploy,
    :download
  ]
  config.x.advanced_sidebar_menu_items = [
    :welcome,
    :sources,
    :plan,
    :deploy,
    :download
  ]
  config.x.menu_items = {
    true  => config.x.advanced_sidebar_menu_items,
    false => config.x.simple_sidebar_menu_items
  }
end
