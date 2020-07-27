class CreateCheckoutSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :checkout_settings do |t|
      t.integer :account_permission, default: 1
      t.boolean :order_notes, default: true
      t.integer :contact, default: 1
      t.boolean :add_info_after_complete_order, default: true
      t.boolean :can_download_app, default: true
      t.integer :full_name_option, default: 1
      t.integer :company_name_option, default: 1
      t.integer :address_2_option, default: 1
      t.integer :shipping_address_phone_option, default: 2
      t.boolean :use_shipping_address_as_billing_address, default: false
      t.boolean :address_autocompletion, default: false
      t.boolean :auto_achive_the_order, default: true
      t.boolean :show_sign_up_at_checkout, default: true
      t.boolean :preselec_sign_up, default: true
      t.boolean :auto_send_abandoned_mails, default: true
      t.integer :abandoned_emails_will_send_to_option, default: 0
      t.integer :time_abandoned_emails_will_send_option, default: 0

      t.timestamps
    end
  end
end
