class AddAttachmentToKeyValues < ActiveRecord::Migration[5.2]
  def change
    add_column :key_values, :attachment, :string
  end
end
