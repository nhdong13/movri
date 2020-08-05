class AddLogoToCheckoutSetting < ActiveRecord::Migration[5.2]
  def change
    add_attachment :checkout_settings, :logo
    add_column :checkout_settings, :logo_position, :integer, default: 0
    add_column :checkout_settings, :logo_size, :integer, default: 1
  end
end
