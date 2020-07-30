class UpdateAgreeSubscriptionToPeople < ActiveRecord::Migration[5.2]
  def change
    add_column :people, :agree_to_subscription, :boolean, default: false
    add_column :people, :note, :string
  end
end
