class CreateStoreGrids < ActiveRecord::Migration[5.2]
  def change
    create_table :store_grids do |t|
      t.references :online_store
      t.string :heading
      t.integer :height, default: 0
      t.integer :text_alignment, default: 0
      t.boolean :maintain_aspect_ratio, default: false
      t.boolean :compress_block, default: 0

      t.timestamps
    end
  end
end
