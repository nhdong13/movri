class AddEnabledToHelpfulLink < ActiveRecord::Migration[5.2]
  def change
    add_column :helpful_links, :enabled, :boolean, default: false
  end
end
