class KeyValue < ApplicationRecord
  self.primary_key = 'key'
  serialize :value
end
