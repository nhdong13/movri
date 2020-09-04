# == Schema Information
#
# Table name: support_infos
#
#  id                 :bigint           not null, primary key
#  image_file_name    :string(255)
#  image_content_type :string(255)
#  image_file_size    :integer
#  image_updated_at   :datetime
#  heading            :string(255)
#  sub_heading        :string(255)
#  phone              :string(255)
#  phone_link         :string(255)
#  email              :string(255)
#  email_link         :string(255)
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class SupportInfo < ApplicationRecord
  has_attached_file :image, :styles => {
                      :small => "108x108#",
                      :thumb => "48x48#",
                      :original => "600x800>"},
                      default_url: "/images/missing_image.png"
  validates_attachment_content_type :image,
                                    :content_type => ["image/jpeg", "image/png", "image/pjpeg"]

  before_save :convert_phone

  def convert_phone
    return unless self.phone
    self.phone = phone.tr("(), ,-", "")
  end

end
