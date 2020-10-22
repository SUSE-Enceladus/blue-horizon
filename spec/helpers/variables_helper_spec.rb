# frozen_string_literal: true

require 'rails_helper'

describe VariablesHelper do
  let(:mock_description) do
    'This description has options and groups in a comment'\
    '<!-- options=[foo,bar] [group:baz] -->'
  end
  let(:expected_options) do
    ['foo', 'bar']
  end

  context 'when selecting options from a description' do
    it 'only parses the options set' do
      expect(helper.get_select_options(mock_description))
        .to eq(expected_options)
    end

    context 'when something goes sideways' do
      it 'returns an empty list' do
        expect(helper.get_select_options(nil)).to eq([])
      end
    end
  end
end
