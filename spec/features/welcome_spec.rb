# frozen_string_literal: true

require 'rails_helper'

describe 'welcome', type: :feature do
  let(:cloud_framework) { 'azure' }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
    populate_sources
    Rails.configuration.x.cloud_framework = cloud_framework
  end

  it 'exists' do
    expect { visit('/welcome') }.not_to raise_error
  end

  it 'is redirected to from the root path' do
    visit('/')
    expect(page).to have_current_path(welcome_path)
  end

  context 'with customized top menu items' do
    before do
      Rails.configuration.x.top_menu_items = [
        {
          key: 'monitor',
          url: '%{monitoring_url}'
        }.with_indifferent_access
      ]

      visit('/welcome')
    end

    after do
      Rails.configuration.x.top_menu_items = nil
    end

    it 'shows the `deploy` menu' do
      selector = '.submenu .main-submenu.visible a.submenu-item.selected'
      expect(page).to have_selector(selector)
      expect(find(selector)).to have_content('Deploy')
    end

    it 'includes disabled custom menu items' do
      expect(find('a.submenu-item.disabled#monitor')).to have_content('Monitor')
      expect(page).to have_link('Monitor', href: '#')
    end
  end
end
