# frozen_string_literal: true

# configure navigation
Rails.application.configure do
  # maps Rails flash contexts to Bootstrap classes
  config.x.flash_context = {
    notice: :success,
    alert:  :warning,
    error:  :danger
  }
  config.x.flash_context.default(:secondary)
end
