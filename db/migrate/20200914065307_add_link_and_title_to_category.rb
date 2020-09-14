class AddLinkAndTitleToCategory < ActiveRecord::Migration[5.2]
  def change
    add_column :categories, :link, :string
    add_column :categories, :display_title, :string
  end
end
