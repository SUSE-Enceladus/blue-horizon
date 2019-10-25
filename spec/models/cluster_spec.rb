require 'rails_helper'

RSpec.describe Cluster, type: :model do
  let(:custom_instance_type) { Faker::Lorem.word }
  let(:subscription) { Faker::Internet.uuid }
  let(:resource_group) { Faker::Lorem.word }
  let(:network) { Faker::Lorem.word }
  let(:subnet) { 'subnet-' + Faker::Number.hexadecimal(digits: 8) }
  let(:security_group) { 'sg-' + Faker::Number.hexadecimal(digits: 8) }
  let(:instance_count) { Faker::Number.within(range: 1..100) }
  let(:storage_account) { Faker::Lorem.word }

  it "can implicitly represent a custom instance type" do
    cluster = described_class.new(instance_type_custom: custom_instance_type)
    expect(cluster.instance_type).to be(custom_instance_type)
  end

  it "can explicity represent a custom instance type" do
    cluster = described_class.new(
      instance_type:        "CUSTOM",
      instance_type_custom: custom_instance_type
    )
    expect(cluster.instance_type).to be(custom_instance_type)
  end

  it "has a constant for minimum cluster size" do
    expect(described_class).to be_const_defined(:MIN_CLUSTER_SIZE)
  end

  it "has a constant for maximum cluster size" do
    expect(described_class).to be_const_defined(:MAX_CLUSTER_SIZE)
  end

  it "calculates the minimum number of nodes required for a cluster" do
    expect(described_class.new.min_nodes_required).to eq(described_class::MIN_CLUSTER_SIZE)
  end

  it "calculates maximum cluster growth" do
    expect(described_class.new.max_nodes_allowed).to eq(described_class::MAX_CLUSTER_SIZE)
  end

  context 'loading' do
    before do
      KeyValue.set(:subscription, subscription)
      KeyValue.set(:instance_type, custom_instance_type)
      KeyValue.set(:instance_count, instance_count)
      KeyValue.set(:storage_account, storage_account)
      KeyValue.set(:resource_group, resource_group)
      KeyValue.set(:network, network)
      KeyValue.set(:subnet, subnet)
      KeyValue.set(:security_group, security_group)
    end

    it 'returns stored values' do
      cluster = described_class.load
      expect(cluster.subscription).to eq(subscription)
      expect(cluster.instance_type).to eq(custom_instance_type)
      expect(cluster.instance_count).to eq(instance_count)
      expect(cluster.storage_account).to eq(storage_account)
      expect(cluster.storage_account).to eq(storage_account)
      expect(cluster.resource_group).to eq(resource_group)
      expect(cluster.network).to eq(network)
      expect(cluster.subnet).to eq(subnet)
      expect(cluster.security_group).to eq(security_group)
    end
  end

  context "when represented as a string" do
    let(:cluster) do
      described_class.new(
        instance_type:  custom_instance_type,
        instance_count: instance_count,
        resource_group: resource_group,
        network:        network,
        subnet:         subnet,
        security_group: security_group
      )
    end

    it "counts out the instances" do
      substring = "a cluster of #{instance_count} #{custom_instance_type} instances"
      expect(cluster.to_s).to match(substring)
    end

    it "describes the resource group" do
      substring = "in the #{resource_group} resource group"
      expect(cluster.to_s).to match(substring)
    end

    it "describes the network" do
      substring = "in the #{network} network"
      expect(cluster.to_s).to match(substring)
    end

    it "describes the subnet" do
      substring = "in the #{subnet} subnet"
      expect(cluster.to_s).to match(substring)
    end

    it "describes the security group" do
      substring = "in the #{security_group} security group"
      expect(cluster.to_s).to match(substring)
    end
  end

  context "when saving, behave like ActiveRecord#save" do
    let(:cluster) { described_class.new }
    let(:handled_exceptions) do
      [
        ActiveRecord::ActiveRecordError.new("Didn't work!"),
      ]
    end

    it "returns true" do
      allow(cluster).to receive(:save!)
      expect(cluster.save).to be(true)
    end

    it "returns false when there is an exception" do
      handled_exceptions.each do |exception|
        allow(cluster).to receive(:save!).and_raise(exception)
        expect(cluster.save).to be(false)
      end
    end

    it "captures downstream messages to the errors collection" do
      handled_exceptions.each do |exception|
        allow(cluster).to receive(:save!).and_raise(exception)
        cluster.save
        expect(cluster.errors[:base]).to include(exception.message)
      end
    end
  end

  context "when framework is Amazon" do
    let(:framework) { "aws" }
    let(:cluster) do
      described_class.new(
        cloud_framework: framework,
        instance_type:   custom_instance_type,
        subnet:          subnet,
        security_group:  security_group
      )
    end

    it "stores instance type as :instance_type KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:instance_type)).to eq(custom_instance_type)
    end

    it "stores subnet ID as :subnet KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:subnet)).to eq(subnet)
    end

    it "stores security group ID as :security_group KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:security_group)).to eq(security_group)
    end

    it "describes the framework in string representation" do
      substring = "in AWS"
      expect(cluster.to_s).to match(substring)
    end
  end

  context "when framework is Azure" do
    let(:framework) { "azure" }
    let(:cluster) do
      described_class.new(
        cloud_framework: framework,
        subscription:    subscription,
        instance_type:   custom_instance_type,
        resource_group:  resource_group,
        network:         network,
        subnet:          subnet,
        storage_account: storage_account
      )
    end

    it "stores subscription id as :subscription_id KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:subscription)).to eq(subscription)
    end

    it "stores storage account as :storage_account KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:storage_account)).to eq(storage_account)
    end

    it "stores instance type as :instance_type KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:instance_type)).to eq(custom_instance_type)
    end

    it "stores resource group name as :resource_group KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:resource_group)).to eq(resource_group)
    end

    it "stores network name as :network KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:network)).to eq(network)
    end

    it "stores subnet name as :subnet KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:subnet)).to eq(subnet)
    end

    it "describes the framework in string representation" do
      substring = "in Azure"
      expect(cluster.to_s).to match(substring)
    end
  end

  context "when framework is Google" do
    let(:framework) { "gcp" }
    let(:cluster) do
      described_class.new(
        cloud_framework: framework,
        instance_type:   custom_instance_type,
        network:         network,
        subnet:          subnet
      )
    end

    it "stores instance type as :instance_type KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:instance_type)).to eq(custom_instance_type)
    end

    it "stores network name as :network KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:network)).to eq(network)
    end

    it "stores subnet name as :subnet KeyValue" do
      expect(cluster.save).to be(true)
      expect(KeyValue.get(:subnet)).to eq(subnet)
    end

    it "describes the framework in string representation" do
      substring = "in GCP"
      expect(cluster.to_s).to match(substring)
    end
  end

end
