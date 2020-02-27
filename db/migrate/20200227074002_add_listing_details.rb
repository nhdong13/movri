class AddListingDetails < ActiveRecord::Migration[5.2]
  def change
    add_column :listings, :spec,               :text
    add_column :listings, :overview,           :text
    add_column :listings, :q_a,                :text
    add_column :listings, :in_the_box,         :text
    add_column :listings, :not_in_the_box,     :text
    add_column :listings, :key_feature,        :text
    add_column :listings, :available_quantity, :integer
    add_column :listings, :sku,                :string
    add_column :listings, :barcode,            :string
    add_column :listings, :track_quantity,     :boolean
    add_column :listings, :contiunue_sell,     :boolean
    add_column :listings, :user_manual,        :string
    add_column :listings, :weight,             :integer
  end
end
