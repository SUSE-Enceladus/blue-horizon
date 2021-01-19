# frozen_string_literal: true

require 'rails_helper'

describe 'planning', type: :feature do
  let(:plan_button) { I18n.t('plan') }

  before do
    populate_sources(include_mocks: false)
  end

  context 'without a current plan' do
    let(:expected_plan_json) { current_plan_fixture_json }
    let(:terra) { Terraform }

    before do
      allow(terra).to receive(:last_action_at).and_return(-1)
      visit(plan_path)
    end

    it 'loads without a pre-generated plan' do
      expect(find('#plan')).to have_no_content
      expect(page).to have_selector('#loading')
    end
  end

  context 'with a current plan' do
    let!(:current_plan) { current_plan_fixture.delete!("\n") }

    it 'displays the current plan' do
      visit(plan_path)
      expect(find('#plan code.output')).to have_content(current_plan)
    end
  end
end
