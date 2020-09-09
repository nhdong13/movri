class CreateCustomStyles < ActiveRecord::Migration[5.2]
  def change
    create_table :custom_styles do |t|
      t.attachment :style_file
      t.text :style_string
      t.timestamps
    end
  end
end
