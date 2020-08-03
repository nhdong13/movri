# == Schema Information
#
# Table name: footer_links
#
#  id                   :bigint           not null, primary key
#  helpful_link_item_id :bigint
#  sub_heading          :string(255)
#  link                 :string(255)
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
# Indexes
#
#  index_footer_links_on_helpful_link_item_id  (helpful_link_item_id)
#

class FooterLink < ApplicationRecord
end
