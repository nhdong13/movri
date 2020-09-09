# == Schema Information
#
# Table name: helpful_link_items
#
#  id              :bigint           not null, primary key
#  helpful_link_id :bigint
#  heading         :string(255)
#  enabled         :boolean          default(FALSE)
#  text            :text(65535)
#  heading_color   :string(255)      default("#334455")
#  text_color      :string(255)      default("#999")
#  content_type    :integer          default("normal")
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_helpful_link_items_on_helpful_link_id  (helpful_link_id)
#

class HelpfulLinkItem < ApplicationRecord
  belongs_to :helpful_link
  has_many :footer_links
  has_many :footer_social_accounts

  accepts_nested_attributes_for :footer_links
  accepts_nested_attributes_for :footer_social_accounts

  enum content_type: %w(normal footer_link social_account sign_up)
  
  def as_json
    sub_items = if self.normal?
      []
    elsif self.footer_link? 
      footer_links.as_json 
    else
      footer_social_accounts.as_json
    end
    super.merge(sub_items: sub_items)
  end
end
