class VariablesController < ApplicationController
  before_action :set_variables

  def show
  end

  def update
    @variables.attributes = variables_params
    if @variables.save
      redirect_to variables_path, flash: {
        notice: 'Variables were successfully updated.'
      }
    else
      render :show, flash: {
        error: @variables.errors.full_messages
      }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_variables
    @variables = Variable.new(Source.terraform.pluck(:content).join)
    # exclude variables handled by cluster sizing
    @excluded = Cluster.variable_handlers
  end

  def variables_params
    params.require(:variables).permit(@variables.strong_params)
  end
end
