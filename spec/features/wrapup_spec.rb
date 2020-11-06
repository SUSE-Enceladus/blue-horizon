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
end
