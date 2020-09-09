class CreateListingAccessories < ActiveRecord::Migration[5.2]
  def change
    create_table :listing_accessories do |t|
      t.string :brand
      t.string :mount
      t.string :lens_type
      t.integer :item_type, default: 0
      t.string :camera_type
      t.string :camcorder_type
      t.string :sensor_size
      t.string :action_cam_compatibility
      t.string :compatibility
      t.string :lighting_type
      t.string :accessory_type
      t.string :capacity
      t.string :memory_type
      t.string :read_transfer_speed
      t.string :bus_speed
      t.string :power_compatibility
      t.string :power_type
      t.string :support_type
      t.string :head_type
      t.string :quick_release_system
      t.string :color_temperature
      t.string :filter_size
      t.string :filter_style
      t.string :filter_type
      t.string :audio_type
      t.string :monitoring_type
      t.string :camera_support_type
      t.string :cable_type
      t.integer :listing_id

      t.timestamps
    end
  end
end
