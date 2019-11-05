require 'rails_helper'

describe 'cluster sizing', type: :feature do
  let!(:sources) { populate_sources }

  describe 'in Azure' do
    let(:cloud_framework) { 'azure' }
    let(:instance_types) { Cloud::InstanceType.for(cloud_framework) }
    let(:random_instance_type_key) { instance_types.sample.key }
    let(:random_cluster_size) do
      Faker::Number.within(
        range: Cluster::MIN_CLUSTER_SIZE..Cluster::MAX_CLUSTER_SIZE
      )
    end

    before :each do
      KeyValue.set(:cloud_framework, cloud_framework)
      visit '/cluster'
    end

    it 'lists the instance types' do
      instance_types.each do |instance_type|
        expect(page).to have_content(instance_type.key)
      end
    end

    it 'stores cluster sizing' do
      choose(random_instance_type_key)
      fill_in('cluster_instance_count', with: random_cluster_size)
      click_on(id: 'submit-cluster')
      cluster = Cluster.load
      expect(cluster.instance_type).to eq(random_instance_type_key)
      expect(cluster.instance_count).to eq(random_cluster_size)
    end
  end
end
