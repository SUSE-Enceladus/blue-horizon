require 'dotenv/load'

if ENV['CLOUD_FRAMEWORK'].present?
  KeyValue.set(:cloud_framework, ENV['CLOUD_FRAMEWORK'])
end
