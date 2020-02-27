class AddAttachmentUserManualToListings < ActiveRecord::Migration[5.2]
  def self.up
    change_table :listings do |t|
      t.attachment :user_manual
    end
  end

  def self.down
    remove_attachment :listings, :user_manual
  end
end
