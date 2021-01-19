# frozen_string_literal: true

require 'rails_helper'

describe 'wrapup', type: :feature do
  let(:mock_template) { 'foo_%{greeting}_bar' }
  let(:expected_output) { 'foo_Hello, World._bar' }

  before do
    terraform_apply(include_mocks: false)
    I18n.backend.store_translations(:en, next_steps: mock_template)
    authorize!
  end

  it 'shows the _next steps_ content rendered in markdown' do
    visit('/wrapup')
    expect(page).to have_content(expected_output)
  end

  context 'with customized top menu items' do
    let(:tuning_url) { 'https://tuning.local' }
    let(:monitoring_url) { 'https://monitoring.local' }
    let(:welcome_path) { '/welcome' }

    before do
      Rails.configuration.x.top_menu_items = [
        {
          key: 'monitor',
          url: '%{monitoring_url}'
        }.with_indifferent_access,
        {
          key:               'tune',
          url:               '%{tuning_url}',
          target_new_window: false
        }.with_indifferent_access,
        {
          key:               'help',
          url:               welcome_path,
          target_new_window: true
        }.with_indifferent_access
      ]

      allow_any_instance_of(Terraform).to receive(:outputs).and_return(
        {
          greeting:       'Hello, World.',
          tuning_url:     tuning_url,
          monitoring_url: monitoring_url
        }
      )

      visit('/wrapup')
    end

    after do
      Rails.configuration.x.top_menu_items = nil
    end

    it 'shows the `deploy` menu' do
      selector = '.submenu .main-submenu.visible a.submenu-item.selected'
      expect(page).to have_selector(selector)
      expect(find(selector)).to have_content('Deploy')
    end

    it 'includes custom menu items' do
      expect(find('a.submenu-item#monitor')).to have_content('Monitor')
      expect(page).to have_link('Monitor', href: monitoring_url)
      expect(page).not_to have_selector(
        'a.submenu-item#monitor[target="_blank"]'
      )

      expect(find('a.submenu-item#tune')).to have_content('Tune')
      expect(page).to have_link('Tune', href: tuning_url)
      expect(page).not_to have_selector('a.submenu-item#tune[target="_blank"]')

      expect(find('a.submenu-item#help')).to have_content('Help')
      expect(page).to have_link('Help', href: welcome_path)
      expect(page).to have_selector('a.submenu-item#help[target="_blank"]')
    end
  end
end
