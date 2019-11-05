require 'rails_helper'

RSpec.describe Variable, type: :model do
  let!(:sources) { populate_sources }
  let(:source_content) { Source.find_by_filename('variables.tf').content }
  let(:subject) { Variable.new(source_content) }
  let(:variable_names) { get_variable_names }

  it 'builds attributes for each variable declaration' do
    variable_names.each do |key|
      expect(subject.respond_to?(key)).to be_truthy
    end
  end

  it 'can be initialized with an empty variable set' do
    expect { Variable.new('') }.not_to raise_error
  end

  it 'uses defaults for attributes' do
    variable_names.each do |key|
      expect(subject.send(key)).to eq subject.default(key)
    end
  end

  context 'loading' do
    let(:fake_data) { Faker::Crypto.sha256 }

    before do
      KeyValue.set('tfvars.ssh_public_key', fake_data)
    end

    it 'returns stored values' do
      expect(subject.ssh_public_key).to eq(fake_data)
    end
  end

  context 'for form handling' do
    it 'presents an attributes hash' do
      expect(subject.respond_to?(:attributes)).to be_truthy
      expect(subject.attributes.keys).to eq(variable_names)
      variable_names.each do |key|
        expect(subject.attributes[key]).to eq subject.default(key)
      end
    end

    it 'presents descriptions' do
      expect(subject.description('test_description')).to eq('test description')
    end

    it 'accepts values via attributes' do
      random_string = Faker::Lorem.word
      random_number = Faker::Number.number(digits: 3)
      random_float = Faker::Number.decimal(l_digits: 3, r_digits: 3)
      attributes_hash = {
        'location'       => random_string,
        'instance_count' => random_number.to_s,
        'empty_number'   => random_float.to_s,
        'are_you_sure'   => 'true',
        'test_list'      => ['one', 'two', 'three'],
        'cluster_labels' => { foo: 'bar' },
        'fake_key'       => 'fake_value'
      }
      expect(Rails.logger).to receive(:warn) # for fake_key
      subject.attributes = attributes_hash
      expect(subject.location).to eq(random_string)
      expect(subject.are_you_sure).to be(true)
      expect(subject.instance_count).to eq(random_number)
      expect(subject.empty_number).to eq(random_float)
      expect(subject.test_list.count).to eq(3)
      expect(subject.cluster_labels.keys).to eq(['foo'])
      expect(subject.instance_variable_names).not_to include('fake_key')
    end

    it 'defines strong params from the variables' do
      expected_params = [
        "resource_group",
        "location",
        "instance_count",
        "instance_type",
        "agent_admin",
        "dns_prefix",
        { "cluster_labels" => {} },
        "disk_size_gb",
        "client_id",
        "client_secret",
        "ssh_public_key",
        "azure_dns_json",
        "are_you_sure",
        { "test_list" => [] },
        "empty_number",
        "test_description"
      ]
      expect(subject.strong_params).to eq(expected_params)
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
      subject.client_id = random_string
      expect { subject.save! }.not_to raise_error
      expect(KeyValue.get('tfvars.client_id')).to eq(random_string)
    end

    it 'returns true' do
      allow(subject).to receive(:save!)
      expect(subject.save).to be(true)
    end

    it 'returns false when there is an exception' do
      handled_exceptions.each do |exception|
        allow(subject).to receive(:save!).and_raise(exception)
        expect(subject.save).to be(false)
      end
    end

    it 'captures downstream messages to the errors collection' do
      handled_exceptions.each do |exception|
        allow(subject).to receive(:save!).and_raise(exception)
        subject.save
        expect(subject.errors[:base]).to include(exception.message)
      end
    end
  end
end
