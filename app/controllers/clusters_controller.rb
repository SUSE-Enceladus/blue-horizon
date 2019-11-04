class ClustersController < ApplicationController
  def show
    @cluster = ClusterSizeSliderDecorator.new(Cluster.load)
    @instance_types = Cloud::InstanceType.for(@cluster.cloud_framework)
  end

  def update
    @cluster = Cluster.new(cluster_params)
    if @cluster.save
      redirect_to variables_path
    else
      render :show, flash: {
        error: @cluster.errors.full_messages
      }
    end
  end

  def cluster_params
    safe_params = params.require(:cluster).permit(
      :cloud_framework, :instance_type, :instance_type_custom, :instance_count,
    )
    safe_params['cloud_framework'] = KeyValue.get(:cloud_framework)
    return safe_params
  end
end
