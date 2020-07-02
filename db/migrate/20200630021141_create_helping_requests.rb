class CreateHelpingRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :helping_requests do |t|
      t.string :person_id
      t.string :subject
      t.string :name
      t.string :email
      t.integer :transaction_id
      t.text :message
      t.timestamps
    end
  end
end
