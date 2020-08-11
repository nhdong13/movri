class CreatePages < ActiveRecord::Migration[5.2]
  def change
    create_table :pages do |t|
      t.string :name
      t.string :url, unique: true, null: false
      t.integer :community_id

      t.timestamps
    end

    add_index :pages, :url
    add_index :pages, :community_id
  end
end
