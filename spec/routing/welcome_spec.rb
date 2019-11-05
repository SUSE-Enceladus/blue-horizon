require 'rails_helper'

describe 'welcome', type: :routing do
  it 'is the root page' do
    expect(get: '/').to route_to('welcome#index')
  end
end
