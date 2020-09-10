class CreateTaxes < ActiveRecord::Migration[5.2]
  def change
    create_table :taxes do |t|
      t.string :province
      t.string :province_display
      t.text :tax_rates
      t.integer :community_id

      t.timestamps
    end

    add_index :taxes, :community_id
  end
end
