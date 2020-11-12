# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ApplicationController, type: :controller do
  context 'when overriding views' do
    let(:vendor_views_path) { Rails.root.join('vendor', 'views').to_s }

    before do
      Rails.configuration.x.override_views = true
      controller.customize_views
    end

    after do
      Rails.configuration.x.override_views = false
    end

    it 'defaults the view path to vendor/views' do
      first_view_path =
        controller.view_paths.paths.first.instance_variable_get(:@path)
      expect(first_view_path).to eq(vendor_views_path)
    end
  end
end
