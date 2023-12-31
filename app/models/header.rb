# == Schema Information
#
# Table name: headers
#
#  id                       :bigint           not null, primary key
#  online_store_id          :integer
#  sticky_enabled           :boolean          default(TRUE)
#  logo_file_name           :string(255)
#  logo_content_type        :string(255)
#  logo_file_size           :integer
#  logo_updated_at          :datetime
#  announcement_enabled     :boolean          default(FALSE)
#  home_only_enabled        :boolean          default(TRUE)
#  title                    :string(255)
#  link                     :string(255)
#  text_color               :string(255)      default("#FFF")
#  background_color         :string(255)      default("#FF0000")
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#  tag_line_setting         :text(65535)
#  phone_number_setting     :text(65535)
#  contact_us_setting       :text(65535)
#  faq_setting              :text(65535)
#  announcement_bar_setting :text(65535)
#
# Indexes
#
#  index_headers_on_online_store_id  (online_store_id)
#

class Header < ApplicationRecord
  belongs_to :online_store
  has_one :slideshow, dependent: :destroy
  has_attached_file :logo, default_url: "/images/missing_image.png"
  validates_attachment_content_type :logo, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

  serialize :tag_line_setting, Hash
  serialize :phone_number_setting, Hash
  serialize :contact_us_setting, Hash
  serialize :faq_setting, Hash
  serialize :announcement_bar_setting, Hash

  def as_json
    json = super
    json['logo_url'] = logo
    json
  end
end
