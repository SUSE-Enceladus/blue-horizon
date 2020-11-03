# frozen_string_literal: true

require 'rails_helper'

describe 'variable editing', type: :feature do
  let(:exclusions) do
    [
      *Cluster.variable_handlers,
      *Region.variable_handlers,
      'test_options',
      'test_file'
    ]
  end
  let(:fake_data) { Faker::Crypto.sha256 }
  let(:terra) { Terraform }
  let(:instance_terra) { instance_double(Terraform) }
  let(:mock_location) { Faker::Internet.slug }

  before { mock_metadata_location(mock_location) }

  context 'with sources' do
    let(:variable_names) { collect_variable_names }
    let(:variables) { Variable.new(Source.variables.pluck(:content)) }

    before do
      allow(terra).to receive(:new).and_return(instance_terra)
      allow(instance_terra).to receive(:validate)
      populate_sources
      visit('/variables')
    end

    it 'has a form entry for each variable' do
      (variable_names - exclusions).each do |key|
        expect(page)
          .to have_selector("[name|='variables[#{key}]']")
          .or have_selector("##{key}_new_value")
      end
    end

    it 'stores form data for variables' do
      random_variable_key = nil
      until random_variable_key &&
            variables.type(random_variable_key) == 'string' &&
            (variables.description(random_variable_key).nil? ||
            variables.description(random_variable_key).exclude?('options'))
        random_variable_key = (variable_names - exclusions).sample
      end
      fill_in("variables[#{random_variable_key}]", with: fake_data)
      find('#next').click

      expect(KeyValue.get(variables.storage_key(random_variable_key)))
        .to eq(fake_data)
    end

    it 'stores form data for variables in multi options input' do
      ['option1', 'option2'].each do |option_value|
        visit('/variables')
        expect(page).to have_select(
          'variables[test_options]',
          with_options: ['option1', 'option2']
        )
        select(option_value, from: 'variables[test_options]')
        find('#next').click

        expect(KeyValue.get(variables.storage_key('test_options')))
          .to eq(option_value)
      end
    end

    context 'when handling files' do
      let(:test_file_name) { 'testfile.txt' }
      let(:test_file_path) do
        Rails.root.join('spec', 'fixtures', test_file_name)
      end
      let(:test_file_contents) { File.read(test_file_path) }

      let(:replacement_file_name) { 'testfile2.txt' }
      let(:replacement_file_path) do
        Rails.root.join('spec', 'fixtures', replacement_file_name)
      end

      before do
        attach_file('variables[test_file]', test_file_path)
        find('#next').click
      end

      it 'stores the file as a source' do
        stored_source = Source.where(filename: test_file_name).first
        expect(stored_source.content).to eq(test_file_contents)
      end

      it 'saves the file name as the value' do
        expect(Variable.load.test_file).to eq(test_file_name)
      end

      it 'does not destroy uploaded files on subsequent submits' do
        visit('/variables')
        find('#next').click
        stored_source = Source.where(filename: test_file_name).first
        expect(stored_source.content).to eq(test_file_contents)
        expect(Variable.load.test_file).to eq(test_file_name)
      end

      it 'replaces uploaded file if a new file is uploaded' do
        visit('/variables')
        attach_file('variables[test_file]', replacement_file_path)
        find('#next').click
        expect(Source.where(filename: test_file_name)).to be_empty
        expect(Variable.load.test_file).to eq(replacement_file_name)
        expect(Source.where(filename: replacement_file_name)).not_to be_empty
      end
    end

    it 'does not display description comments' do
      expect(page).to have_content 'Some things'
      expect(page).not_to have_content 'are best left unsaid'
    end

    it 'stores from data for variables validating the pattern' do
      pattern_input = page.find("[name|='variables[test_pattern]']")
      expect(pattern_input[:title]).to eq('2 digits string')
      expect(pattern_input[:pattern]).to eq('[0-9]{2}')
    end

    it 'fails to update and shows error' do
      random_variable_key = nil
      until random_variable_key &&
            variables.type(random_variable_key) == 'string' &&
            (variables.description(random_variable_key).nil? ||
            variables.description(random_variable_key).exclude?('options'))
        random_variable_key = (variable_names - exclusions).sample
      end
      fill_in("variables[#{random_variable_key}]", with: fake_data)
      allow(Variable).to receive(:new).and_return(variables)
      allow(variables).to receive(:save).and_return(false)
      active_model_errors = ActiveModel::Errors.new(variables).tap do |e|
        e.add(:variable, 'is wrong')
      end
      allow(variables).to receive(:errors).and_return(active_model_errors)
      find('#next').click

      expect(page).not_to have_content('Variables were successfully updated.')
      expect(page).to have_content('Variable is wrong')
    end
  end

  it 'notifies that no variables are defined' do
    allow(terra).to receive(:new).and_return(instance_terra)
    allow(instance_terra).to receive(:validate)

    visit('/variables')
    expect(page).to have_content('No variables are defined!')
  end

  it 'shows script error on page' do
    allow(Variable).to receive(:load).and_return(error: 'wrong')
    warning_message = I18n.t('flash.invalid_variables')
    visit('/variables')
    expect(page).not_to have_content('No variables are defined!')
    expect(page).to have_content('wrong').and have_content(warning_message)
  end
end
