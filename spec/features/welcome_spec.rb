require 'rails_helper'

describe 'welcome', type: :feature do
  it 'exists' do
    expect { visit('/welcome') }.not_to raise_error
  end
end
