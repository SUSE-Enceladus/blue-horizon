# frozen_string_literal: true

require 'ruby_terraform'

class VariablesController < ApplicationController
  before_action :set_variables

  def show
    return if @variables.attributes.present?

    flash.now[:alert] = 'No variables are defined!'
  end

  def update
    @variables.attributes = variables_params
    redirect_to plan_path and return if @variables.save

    redirect_to variables_path, flash: {
      error: @variables.errors.full_messages
    }
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_variables
    @variables = Variable.load
    if @variables.is_a?(Hash) && @variables[:error]
      redirect_to sources_path, flash: {
        error: @variables[:error], warning: 'Please, edit the scripts'
      }
    end
    # exclude variables handled by cluster sizing
    @excluded = Cluster.variable_handlers
    # set region automatically, if possibe
    return unless @variables.respond_to? :region

    region = Region.load
    return unless region.set_by_metadata

    region.save
    @excluded += Region.variable_handlers
  end

  def variables_params
    params[:variables][:cluster_labels] ||= {}
    params.require(:variables).permit(@variables.strong_params)
  end
end
