# == Schema Information
#
# Table name: footer_social_accounts
#
#  id                 :bigint           not null, primary key
#  helpful_link_id    :bigint
#  alt_text           :string(255)
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  link               :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#
# Indexes
#
#  index_footer_social_accounts_on_helpful_link_id  (helpful_link_id)
#

class FooterSocialAccount < ApplicationRecord
end
