# frozen_string_literal: true

require 'rails_helper'

describe 'welcome', type: :feature do
  let(:cloud_framework) { 'azure' }

  before do
    populate_sources
    KeyValue.set(:cloud_framework, cloud_framework)
  end

  it 'exists' do
    expect { visit('/welcome') }.not_to raise_error
  end

  describe 'on the simple path' do
    before do
      visit('/welcome')
      within('#content') do
        click_on('Start setup')
      end
    end

    it 'has a trigger link' do
      expect(Rails.configuration.x.advanced_mode).to be_falsey
    end

    it 'redirects to the next step' do
      expect(page).to have_current_path(cluster_path)
    end
  end

  describe 'on the advanced path' do
    before do
      visit('/welcome')
      within('#content') do
        click_on('Edit sources')
      end
    end

    it 'has a trigger link' do
      expect(Rails.configuration.x.advanced_mode).to be_truthy
    end

    it 'redirects to the next step' do
      expect(page).to have_current_path(sources_path)
    end
  end
end
