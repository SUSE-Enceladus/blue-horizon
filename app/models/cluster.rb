# CloudCluster represents user-configured attributes of a cloud deployment.
class Cluster
  include ActiveModel::Model
  attr_accessor :cloud_framework,
    :instance_count, :instance_type, :instance_type_custom, :subnet,
    :security_group, # EC2 profile
    :subscription, # Azure provider
    :storage_account, :resource_group, :network # Azure profile

  MIN_CLUSTER_SIZE = 3
  MAX_CLUSTER_SIZE = 250

  def initialize(*args)
    super
    if @instance_type.blank? || @instance_type == "CUSTOM"
      @instance_type = @instance_type_custom
    end
    @instance_count = @instance_count.to_i
  end

  def self.load
    self.new(
      cloud_framework: KeyValue.get(:cloud_framework),
      instance_count: KeyValue.get(:instance_count),
      instance_type: KeyValue.get(:instance_type),
      instance_type_custom: KeyValue.get(:instance_type_custom),
      subnet: KeyValue.get(:subnet),
      security_group: KeyValue.get(:security_group),
      subscription: KeyValue.get(:subscription),
      storage_account: KeyValue.get(:storage_account),
      resource_group: KeyValue.get(:resource_group),
      network: KeyValue.get(:network)
    )
  end

  def self.variable_handlers
    [
      'instance_type',
      'instance_count'
    ]
  end

  def current_cluster_size
    0 # TODO: will we support resizing?
  end

  def min_nodes_required
    [0, MIN_CLUSTER_SIZE - current_cluster_size].max
  end

  def max_nodes_allowed
    MAX_CLUSTER_SIZE - current_cluster_size
  end

  # attributes that will be described via to_s as a scoping description
  def string_scoping_attributes
    [:resource_group, :network, :subnet, :security_group]
  end

  def to_s
    parts = ["a cluster of #{@instance_count} #{@instance_type} instances"]
    string_scoping_attributes.each do |attribute|
      parts.push(string_scope_if(attribute))
    end
    case @cloud_framework
    when "aws"
      parts.push("in AWS")
    when "azure"
      parts.push("in Azure")
    when "gcp"
      parts.push("in GCP")
    end
    parts.compact.join(" ")
  end

  def save!
    KeyValue.set(:subscription, @subscription)
    KeyValue.set(:instance_type, @instance_type)
    KeyValue.set(:instance_count, @instance_count)
    KeyValue.set(:storage_account, @storage_account)
    KeyValue.set(:resource_group, @resource_group)
    KeyValue.set(:network, @network)
    KeyValue.set(:subnet, @subnet)
    KeyValue.set(:security_group, @security_group)
  end

  def save
    save!
    return true
  rescue ActiveRecord::ActiveRecordError => e
    errors[:base] << e.message
    return false
  end

  private

  def string_scope_if(attribute)
    value = send(attribute)
    description = attribute.to_s.humanize(capitalize: false)
    return if value.blank?

    "in the #{value} #{description}"
  end
end
