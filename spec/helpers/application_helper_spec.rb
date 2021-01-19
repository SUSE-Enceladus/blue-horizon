# frozen_string_literal: true

require 'rails_helper'

describe ApplicationHelper do
  context 'when prettifying JSON' do
    it 'handles errors gracefully' do
      expect(helper.pretty_json(nil)).to eq('')
    end
  end
end
