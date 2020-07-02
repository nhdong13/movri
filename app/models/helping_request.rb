# == Schema Information
#
# Table name: helping_requests
#
#  id             :bigint           not null, primary key
#  person_id      :string(255)
#  subject        :string(255)
#  name           :string(255)
#  email          :string(255)
#  transaction_id :integer
#  message        :text(65535)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class HelpingRequest < ApplicationRecord
  belongs_to :tx, class_name: "Transaction", foreign_key: "transaction_id", inverse_of: :helping_request
  belongs_to :person
end
