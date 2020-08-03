class ChangeTypeColumnAddress < ActiveRecord::Migration[5.2]
  def change
    change_column :transaction_addresses, :person_id, :string
  end
end
