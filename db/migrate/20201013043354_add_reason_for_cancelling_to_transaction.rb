class AddReasonForCancellingToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :reason_for_cancelling, :string
  end
end
