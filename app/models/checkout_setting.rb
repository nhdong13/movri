# == Schema Information
#
# Table name: checkout_settings
#
#  id                                      :bigint           not null, primary key
#  account_permission                      :integer          default("guest_or_accounts")
#  order_notes                             :boolean          default(TRUE)
#  contact                                 :integer          default("checkout_with_email")
#  add_info_after_complete_order           :boolean          default(TRUE)
#  can_download_app                        :boolean          default(TRUE)
#  full_name_option                        :integer          default("require_fullname")
#  company_name_option                     :integer          default("optional_company_name")
#  address_2_option                        :integer          default("optional_address_2")
#  shipping_address_phone_option           :integer          default("required_shipping_address_phone")
#  use_shipping_address_as_billing_address :boolean          default(FALSE)
#  address_autocompletion                  :boolean          default(FALSE)
#  auto_achive_the_order                   :boolean          default(TRUE)
#  show_sign_up_at_checkout                :boolean          default(TRUE)
#  preselect_sign_up                       :boolean          default(TRUE)
#  auto_send_abandoned_mails               :boolean          default(FALSE)
#  abandoned_emails_will_send_to_option    :integer          default("abandoned_people")
#  time_abandoned_emails_will_send_option  :integer          default("one_hour")
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  logo_file_name                          :string(255)
#  logo_content_type                       :string(255)
#  logo_file_size                          :integer
#  logo_updated_at                         :datetime
#  logo_position                           :integer          default("left")
#  logo_size                               :integer          default("medium")
#

# check this for more details
# https://wireframepro.mockflow.com/editor.jsp?editor=off&perm=Owner&projectid=M2602e1910c735195818994a5edf7e9511568784787576&publicid=ef6edaa6ec5b4ff3b81abcdc9f0077a7#/page/D1499ac86752c63f44a9cf12d3257f430
class CheckoutSetting < ApplicationRecord
  enum account_permission: [:only_guest, :guest_or_accounts, :only_accounts]
  enum contact: [:checkout_with_phone_or_email, :checkout_with_email]
  enum full_name_option: [:require_last_name_only, :require_fullname]
  enum company_name_option: [:hidden_company_name, :optional_company_name, :required_company_name]
  enum address_2_option: [:hidden_address_2, :optional_address_2, :required_address_2]
  enum shipping_address_phone_option: [:hidden_shipping_address_phone, :optional_shipping_address_phone, :required_shipping_address_phone]
  enum abandoned_emails_will_send_to_option: [:abandoned_people, :abandoned_emails]
  enum time_abandoned_emails_will_send_option: [:one_hour, :six_hours, :ten_hours, :twenty_four_hours]
  enum logo_position: [:left, :center, :right]
  enum logo_size: [:small, :medium, :large]

  # see paperclip (for image_processing column)
  has_attached_file :logo,
    :styles => {
      :small => "240x160#",
      :medium => "360x270#",
      :thumb => "120x120#",
      :original => "#{APP_CONFIG.original_image_width}x#{APP_CONFIG.original_image_height}>",
      :email => "150x100#",
      :square => "408x408#",
      :large => "816x816#"
    }

  validates_attachment_content_type :logo,
                                    :content_type => ["image/jpeg", "image/png", "image/gif", "image/pjpeg", "image/x-png"], # the two last types are sent by IE.
                                    :unless => Proc.new {|model| model.logo.nil? }

end
