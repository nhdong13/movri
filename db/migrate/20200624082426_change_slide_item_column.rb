class ChangeSlideItemColumn < ActiveRecord::Migration[5.2]
  def change
    rename_column :slide_items, :button_lable, :button_label
  end
end
