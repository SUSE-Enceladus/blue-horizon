class KeyValue < ApplicationRecord
  self.primary_key = 'key'
  serialize :value

  def self.set(key, value)
    kv = begin
      KeyValue.find(key)
    rescue ActiveRecord::RecordNotFound
      KeyValue.new(key: key)
    end
    kv.value = value
    kv.save
  end

  def self.get(key, default_value=nil)
    begin
      KeyValue.find(key).value
    rescue ActiveRecord::RecordNotFound
      default_value
    end
  end
end
