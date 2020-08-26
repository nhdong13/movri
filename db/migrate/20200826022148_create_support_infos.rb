class CreateSupportInfos < ActiveRecord::Migration[5.2]
  def change
    create_table :support_infos do |t|
      t.attachment :image
      t.string :heading
      t.string :sub_heading
      t.string :phone
      t.string :phone_link
      t.string :email
      t.string :email_link
      t.timestamps
    end
  end
end
