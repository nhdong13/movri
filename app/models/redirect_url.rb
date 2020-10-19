# == Schema Information
#
# Table name: redirect_urls
#
#  id                :bigint           not null, primary key
#  from              :string(255)
#  to                :string(255)
#  community_id      :integer
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  redirectable_id   :integer
#  redirectable_type :string(255)
#
# Indexes
#
#  index_redirect_urls_on_community_id                           (community_id)
#  index_redirect_urls_on_redirectable_id_and_redirectable_type  (redirectable_id,redirectable_type)
#

class RedirectUrl < ApplicationRecord
  belongs_to :community
  belongs_to :redirectable, polymorphic: true, optional: true

  before_save :set_default_url
  validates :from, uniqueness: true

  private

  def set_default_url
    from = "/" unless from
    to = "/" unless to
  end
end
