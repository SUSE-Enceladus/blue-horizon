# frozen_string_literal: true

require 'rails_helper'

describe 'authorization', type: :feature do
  let(:cloud_framework) { 'azure' }
  let(:random_path) do
    Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
  end
  let(:auth_message) { 'Sorry, you can\'t do that, yet.' }

  before do
    populate_sources
    KeyValue.set(:cloud_framework, cloud_framework)
  end

  it 'always allows access to the welcome page' do
    visit '/welcome'
    expect(page).not_to have_content(auth_message)
  end

  it 'initially blocks access to deploy' do
    visit '/deploy'
    expect(page).to have_current_path(welcome_path)
    expect(page).to have_content(auth_message)
  end

  it 'initially blocks access to download' do
    visit '/download'
    expect(page).to have_current_path(welcome_path)
    expect(page).to have_content(auth_message)
  end

  describe 'after planning' do
    before do
      FileUtils.mkdir_p(random_path)
      Rails.configuration.x.source_export_dir = random_path
      artifact = Rails.configuration.x.source_export_dir.join('current_plan')
      File.open(artifact, 'w') {}
    end

    after do
      FileUtils.rm_rf(random_path)
    end

    it 'allows access to deploy' do
      visit '/deploy'
      expect(page).to have_current_path(deploy_path)
      expect(page).not_to have_content(auth_message)
    end

    it 'raises StandardError while checking access to deploy' do
      allow(Rails.configuration.x.source_export_dir).to(
        receive(:join)
          .and_raise(StandardError)
      )
      visit '/deploy'
      expect(page).to have_current_path(welcome_path)
      expect(page).to have_content(auth_message)
    end

    describe 'after deploy' do
      before do
        artifact = Rails.configuration.x.source_export_dir.join('tf-apply.log')
        File.open(artifact, 'w') {}
      end

      it 'allows access to download' do
        visit '/download'
        expect(page).to have_current_path(download_path)
      end
    end
  end
end
