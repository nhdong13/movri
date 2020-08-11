class AddCanceledNoteToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :canceled_order_note, :string
  end
end
