require 'rails_helper'

describe 'source editing', type: :feature do
  let!(:sources) { populate_sources }
  let(:variable_names) { get_variable_names }
  let(:exclusions) { Cluster.variable_handlers }
  let(:variables) { Variable.new(Source.terraform.pluck(:content).join) }
  let(:fake_data) { Faker::Crypto.sha256 }

  before :each do
    visit('/variables')
  end

  it 'has a form entry for each variable' do
    (variable_names - exclusions).each do |key|
      expect(page).to have_selector("[name|='variables[#{key}]']").or have_selector("##{key}_new_value")
    end
  end

  it 'stores form data for variables' do
    random_variable_key = nil
    until random_variable_key && variables.type(random_variable_key) == 'string' do
      random_variable_key = (variable_names - exclusions).sample
    end
    fill_in("variables[#{random_variable_key}]", with: fake_data)
    click_on('Save')

    expect(KeyValue.get(variables.storage_key(random_variable_key))).to eq(fake_data)
  end
end
