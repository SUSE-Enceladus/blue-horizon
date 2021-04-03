# frozen_string_literal: true

require 'rails_helper'

RSpec.describe K8sVersion, type: :model do
  let(:location) { 'fake-region-1' }
  let(:expected_version) { 'latest' }
  let(:subject) { described_class.load() }

  before do
    described_class.prefixed_set(:location, location)
  end

  context 'when cloud framework is AWS' do
    let(:access_key_id) { Faker::Alphanumeric.alpha(number: 20) }
    let(:secret_access_key) { Faker::Alphanumeric.alpha(number: 40) }

    before do
      Rails.configuration.x.cloud_framework = 'aws'
      described_class.prefixed_set(:access_key_id, access_key_id)
      described_class.prefixed_set(:secret_access_key, secret_access_key)
    end

    it 'calls the external script with a proper command' do
      expected_script = "get-framework-k8s-api-version ec2 "\
      "--aws-access-key-id #{access_key_id} "\
      "--aws-secret-access-key #{secret_access_key} "\
      "--region-name #{location}"
      expect(Open3).to receive(:capture3).with(expected_script)
      subject.save!
    end

    it 'sets the k8s_version variable' do
      expect(Open3).to receive(:capture3).and_return(expected_version)
      subject.save!
      expect(described_class.prefixed_get(:k8s_version)).to eq(expected_version)
    end
  end

  context 'when cloud framework is Azure' do
    let(:client_id) { Faker::Internet.uuid }
    let(:client_secret) { Faker::Internet.uuid }
    let(:tenant_id) { Faker::Internet.uuid }
    let(:subscription_id) { Faker::Internet.uuid }

    before do
      Rails.configuration.x.cloud_framework = 'azure'
      described_class.prefixed_set(:client_id, client_id)
      described_class.prefixed_set(:client_secret, client_secret)
      described_class.prefixed_set(:tenant_id, tenant_id)
      described_class.prefixed_set(:subscription_id, subscription_id)
    end

    it 'calls the external script with a proper command' do
      expected_script = "get-framework-k8s-api-version az "\
        "--client-id #{client_id} "\
        "--client-secret #{client_secret} "\
        "--tenant-id #{tenant_id} "\
        "--subscription-id #{subscription_id} "\
        "--location #{location}"
      expect(Open3).to receive(:capture3).with(expected_script)
      subject.save!
    end

    it 'sets the k8s_version variable' do
      expect(Open3).to receive(:capture3).and_return(expected_version)
      subject.save!
      expect(described_class.prefixed_get(:k8s_version)).to eq(expected_version)
    end
  end

  context 'when cloud framework is GCP' do
    before do
      Rails.configuration.x.cloud_framework = 'gcp'
    end

    it 'sets the k8s_version variable' do
      subject.save!
      expect(described_class.prefixed_get(:k8s_version)).to eq(expected_version)
    end
  end
end
