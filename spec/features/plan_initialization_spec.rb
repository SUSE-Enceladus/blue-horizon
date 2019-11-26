# frozen_string_literal: true

require 'rails_helper'

describe 'plan initialization' do

  context 'when configuring terraform' do

    it 'sets the configuration' do
      config = stubbed_ruby_terraform_config
      allow_any_instance_of(PlansController).to receive(:init_terraform)
      expect(RubyTerraform).to receive(:configure).and_yield(config)
      visit('/plan')
    end

    it 'initialize terraform' do
      allow_any_instance_of(PlansController).to receive(:config_terraform)
      expect(RubyTerraform).to receive(:init)
      visit('/plan')
    end
  end
end
