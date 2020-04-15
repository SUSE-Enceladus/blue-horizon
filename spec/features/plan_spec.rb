# frozen_string_literal: true

require 'rails_helper'

describe 'planning', type: :feature do
  let!(:export_path) { random_export_path }
  let(:plan_button) { I18n.t('plan') }

  before do
    FileUtils.mkdir_p(export_path)
    populate_sources(false, false)
  end

  after do
    FileUtils.rm_rf(export_path)
  end

  context 'without a current plan' do
    let(:expected_plan_json) { current_plan_fixture_json }

    before do
      visit(plan_path)
    end

    it 'loads without a pre-generated plan' do
      expect(find('code.output')).to have_no_content
    end

    it 'generates a new plan' do
      click_on(id: 'submit-plan')

      expect(JSON.parse(find('code.output').text))
        .to eq(JSON.parse(expected_plan_json))
      expect(File.exist?(export_path.join('current_plan')))
        .to be true
    end
  end

  context 'with a current plan' do
    let!(:current_plan) { current_plan_fixture }

    it 'displays the current plan' do
      visit(plan_path)
      expect(find('code.output')).to have_content(current_plan)
    end
  end
end
