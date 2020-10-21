# frozen_string_literal: true

# Key/Value store on ActiveRecord
class KeyValue < ApplicationRecord
  self.primary_key = 'key'
  serialize :value
  mount_uploader :attachment, AttachmentUploader

  def self.set(key, value)
    kv =
      begin
        find(key.to_s)
      rescue ActiveRecord::RecordNotFound
        new(key: key)
      end

    kv.value = value
    if value.is_a?(ActionDispatch::Http::UploadedFile)
      kv.attachment = value
    end

    kv.save

    return unless value.is_a?(ActionDispatch::Http::UploadedFile)

    # We need to save the value with the final path, that is created
    # after the 1st save
    kv.value = kv.attachment.current_path
    kv.save
  end

  def self.get(key, default_value=nil)
    find(key.to_s).value
  rescue ActiveRecord::RecordNotFound
    default_value
  end
end
