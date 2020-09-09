class CreateFooterSocialAccounts < ActiveRecord::Migration[5.2]
  def change
    create_table :footer_social_accounts do |t|
      t.references :helpful_link_item
      t.string :alt_text
      t.attachment :image
      t.string :link

      t.timestamps
    end
  end
end
