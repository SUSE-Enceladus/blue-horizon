# frozen_string_literal: true

require 'rails_helper'

describe VariablesHelper do
  context 'when selecting options from a description' do
    context 'when something goes sideways' do
      it 'returns an empty list' do
        expect(helper.get_select_options(nil)).to eq([])
      end
    end
  end
end
