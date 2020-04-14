# frozen_string_literal: true

require 'rails_helper'

describe 'authorization', type: :feature do
  let(:cloud_framework) { 'azure' }
  let(:random_path) do
    Rails.root.join('tmp', Faker::File.dir(segment_count: 1))
  end
  let(:auth_message) { 'Sorry, you can\'t do that, yet.' }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }

  before do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)
    populate_sources
    KeyValue.set(:cloud_framework, cloud_framework)
  end

  it 'always allows access to the welcome page' do
    visit '/welcome'
    expect(page).not_to have_content(auth_message)
  end

  it 'initially blocks access to deploy' do
    allow(File).to receive(:exist?).and_return(false)

    visit '/deploy'

    expect(page).to have_current_path(welcome_path)
    expect(page).to have_content(auth_message)
  end

  it 'initially blocks access to download' do
    allow(File).to receive(:exist?).and_return(false)

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
        File.open(Terraform.statefilename, 'w') {}
      end

      it 'allows access to download' do
        visit '/download'
        expect(page).to have_current_path(download_path)
      end
    end
  end

  describe 'with an active session' do
    let(:active_session_id) { Faker::Crypto.md5 }
    let(:active_session_ip) { Faker::Internet.ip_v4_address }
    let(:session_lock_message) { I18n.t('non_active_session') }
    let(:reset_session) { I18n.t('action.reset_session') }

    before do
      create(:key_value, key: 'active_session_id', value: active_session_id)
      create(:key_value, key: 'active_session_ip', value: active_session_ip)
    end

    it 'only allows access to welcome page' do
      Rails.configuration.x.simple_sidebar_menu_items.each do |path|
        visit("/#{path}")
        expect(page).to have_current_path(welcome_path)
        expect(page).to have_content(session_lock_message)
      end
    end

    it 'warns of additional session' do
      visit(welcome_path)
      expect(page).to have_content(session_lock_message)
    end

    it 'allows session lock to be reset' do
      visit(welcome_path)
      within('#locked-session') do
        click_on(reset_session)
      end
      expect(page).to have_current_path(welcome_path)
      expect(page).not_to have_content(session_lock_message)
    end
  end
end
