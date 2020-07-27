# == Schema Information
#
# Table name: redirect_urls
#
#  id           :bigint           not null, primary key
#  from         :string(255)
#  to           :string(255)
#  community_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_redirect_urls_on_community_id  (community_id)
#

class RedirectUrl < ApplicationRecord
  belongs_to :community

  before_save :set_default_url

  private

  def set_default_url
    from = "/" unless from
    to = "/" unless to
  end
end
