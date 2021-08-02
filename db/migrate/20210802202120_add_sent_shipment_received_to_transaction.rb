class AddSentShipmentReceivedToTransaction < ActiveRecord::Migration[5.2]
  def change
    add_column :transactions, :sent_shipment_received_mail, :boolean, default: false
  end
end
