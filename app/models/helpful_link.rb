# == Schema Information
#
# Table name: helpful_links
#
#  id              :bigint           not null, primary key
#  online_store_id :bigint
#  heading         :string(255)
#  content_type    :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  enabled         :boolean          default(FALSE)
#
# Indexes
#
#  index_helpful_links_on_online_store_id  (online_store_id)
#

class HelpfulLink < ApplicationRecord
  include Sectionable

  has_many :helpful_link_items, dependent: :destroy

  def as_json
    super.merge(items: helpful_link_items.as_json)
  end
end
