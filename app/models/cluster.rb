# CloudCluster represents user-configured attributes of a cloud deployment.
class Cluster
  include ActiveModel::Model
  attr_accessor :cloud_framework,
    :instance_count, :instance_type, :instance_type_custom

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
      instance_type_custom: KeyValue.get(:instance_type_custom)
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

  def to_s
    parts = ["a cluster of #{@instance_count} #{@instance_type} instances"]
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
    KeyValue.set(:instance_type, @instance_type)
    KeyValue.set(:instance_count, @instance_count)
  end

  def save
    save!
    return true
  rescue ActiveRecord::ActiveRecordError => e
    errors[:base] << e.message
    return false
  end
end
