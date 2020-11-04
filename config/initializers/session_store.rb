# frozen_string_literal: true

# configure navigation
Rails.application.configure do
  config.session_store :cookie_store, same_site: :lax
end
