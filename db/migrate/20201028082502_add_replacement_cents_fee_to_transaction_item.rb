class AddReplacementCentsFeeToTransactionItem < ActiveRecord::Migration[5.2]
  def change
    add_column :transaction_items, :replacement_cents_fee, :integer, default: 0
    TransactionItem.all.each do |item|
      listing = item.listing
      if listing
        item.update(replacement_cents_fee: listing.replacement_cents_fee)
      else
        item.update(replacement_cents_fee: 0)
      end
    end
  end
end
