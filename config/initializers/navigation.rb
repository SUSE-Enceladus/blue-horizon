# frozen_string_literal: true

# configure navigation
Rails.application.configure do
  # EOS icon names for each navigation path
  config.x.sidebar_icons = {
    welcome:   'announcement',
    cluster:   'photo_size_select_small',
    variables: 'playlist_add',
    plan:      'organization',
    deploy:    'play_arrow',
    wrapup:    'enhancement',
    download:  'archive'
  }

  # menus for each path
  config.x.menu_items = [
    :welcome,
    :cluster,
    :variables,
    :plan,
    :deploy,
    :wrapup
  ]

  config.x.external_instance_types_link = {
    'azure' => 'https://docs.microsoft.com/azure/virtual-machines/linux/sizes/',
    'aws'   => 'https://aws.amazon.com/ec2/instance-types/',
    'gcp'   => 'https://cloud.google.com/compute/docs/machine-types'
  }

  config.x.source_link = 'https://github.com/SUSE-Enceladus/blue-horizon/'
end
