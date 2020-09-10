class CreatePaddingTimes < ActiveRecord::Migration[5.2]
  def change
    create_table :padding_times do |t|
      t.integer :listing_id
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
