# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Variable, type: :model do
  let(:source_content) { Source.find_by_filename('variables.tf').content }
  let(:variables) { described_class.new(source_content) }
  let(:variable_names) { collect_variable_names }

  before do
    populate_sources
  end

  it 'builds attributes for each variable declaration' do
    variable_names.each do |key|
      expect(variables).to respond_to(key)
    end
  end

  it 'can be initialized with an empty variable set' do
    expect { described_class.new('') }.not_to raise_error
  end

  it 'uses defaults for attributes' do
    variable_names.each do |key|
      expect(variables.send(key)).to eq(variables.default(key))
    end
  end

  context 'when loading' do
    let(:fake_data) { Faker::Crypto.sha256 }

    before do
      KeyValue.set('tfvars.ssh_public_key', fake_data)
    end

    it 'returns stored values' do
      expect(variables.ssh_public_key).to eq(fake_data)
    end
  end

  context 'with form handling' do
    let(:random_string) { Faker::Lorem.word }
    let(:random_number) { Faker::Number.number(digits: 3) }
    let(:random_float) { Faker::Number.decimal(l_digits: 3, r_digits: 3) }
    let(:expected_params) do
      [
        'resource_group',
        'location',
        'instance_count',
        'instance_type',
        'agent_admin',
        'dns_prefix',
        { 'cluster_labels' => {} },
        'disk_size_gb',
        'client_id',
        'client_secret',
        'ssh_public_key',
        'azure_dns_json',
        'are_you_sure',
        { 'test_list' => [] },
        'empty_number',
        'test_description'
      ]
    end

    it 'presents an attributes hash' do
      expect(variables).to respond_to(:attributes)
      expect(variables.attributes.keys).to eq(variable_names)
      variable_names.each do |key|
        expect(variables.attributes[key]).to eq variables.default(key)
      end
    end

    it 'defines strong params from the variables' do
      expect(variables.strong_params).to eq(expected_params)
    end

    it 'presents descriptions' do
      expect(variables.description('test_description')).to eq('test description')
    end

    context 'with form params' do
      let(:attributes_hash) do
        {
          'location'       => random_string,
          'instance_count' => random_number.to_s,
          'empty_number'   => random_float.to_s,
          'are_you_sure'   => 'true',
          'test_list'      => ['one', 'two', 'three'],
          'cluster_labels' => { foo: 'bar' },
          'fake_key'       => 'fake_value'
        }
      end

      before do
        allow(Rails.logger).to receive(:warn)
        variables.attributes = attributes_hash
      end

      it 'accepts values via attributes' do
        expect(variables.location).to eq(random_string)
      end

      it 'casts number from string' do
        expect(variables.instance_count).to eq(random_number)
        expect(variables.empty_number).to eq(random_float)
      end

      it 'casts boolean from string' do
        expect(variables.are_you_sure).to be(true)
      end

      it 'accepts lists' do
        expect(variables.test_list.count).to eq(3)
      end

      it 'accepts hashes' do
        expect(variables.cluster_labels.keys).to eq(['foo'])
      end

      it 'logs a warning for fake attributes' do
        expect(variables.instance_variable_names).not_to include('fake_key')
        expect(Rails.logger).to have_received(:warn) # for fake_key
      end
    end
  end

  context 'when saving, behave like ActiveRecord#save' do
    let(:random_string) { Faker::Lorem.word }
    let(:handled_exceptions) do
      [
        ActiveRecord::ActiveRecordError.new('Didn\'t work!')
      ]
    end

    it 'performs save!' do
      variables.client_id = random_string
      expect { variables.save! }.not_to raise_error
      expect(KeyValue.get('tfvars.client_id')).to eq(random_string)
    end

    it 'returns true' do
      allow(variables).to receive(:save!)
      expect(variables.save).to be(true)
    end

    it 'returns false when there is an exception' do
      handled_exceptions.each do |exception|
        allow(variables).to receive(:save!).and_raise(exception)
        expect(variables.save).to be(false)
      end
    end

    it 'captures downstream messages to the errors collection' do
      handled_exceptions.each do |exception|
        allow(variables).to receive(:save!).and_raise(exception)
        variables.save
        expect(variables.errors[:base]).to include(exception.message)
      end
    end
  end
end
