require 'rails_helper'

RSpec.describe KeyValue, type: :model do
  it 'has unique keys' do
    static_key = 'static'
    create(:key_value, key: static_key)
    expect {
      create(:key_value, key: static_key)
    }.to raise_error(ActiveRecord::RecordNotUnique)
  end

  it 'is accessible by key' do
    key = create(:key_value).key
    KeyValue.find(key)
  end

  context 'handles different types of values' do
    shared_examples 'type-specifc storage' do |value|
      let(:key) {create(:key_value, value: value).key }

      it 'returns the same value' do
        expect(KeyValue.find(key).value).to eq value
      end

      it 'returns the same class of value' do
        expect(KeyValue.find(key).value).to be_a value.class
      end
    end

    it_behaves_like 'type-specifc storage', Faker::String.random
    it_behaves_like 'type-specifc storage', Faker::Number.decimal
    it_behaves_like 'type-specifc storage', Faker::Time.forward(days: 1)
    it_behaves_like 'type-specifc storage', Faker::Boolean.boolean
  end
end
