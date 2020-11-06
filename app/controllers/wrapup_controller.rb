# frozen_string_literal: true

class WrapupController < ApplicationController
  def index
    @outputs = Terraform.new.outputs
    @content = t('next_steps') % @outputs
  end
end
