# == Schema Information
#
# Table name: custom_styles
#
#  id                      :bigint           not null, primary key
#  style_file_file_name    :string(255)
#  style_file_content_type :string(255)
#  style_file_file_size    :integer
#  style_file_updated_at   :datetime
#  style_string            :text(65535)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

class CustomStyle < ApplicationRecord
  has_attached_file :style_file, { s3_headers: {'Content-Type' => 'text/css'}}
  validates_attachment_file_name :style_file, :matches => [/css\Z/]
  after_save :rewrite_file_css, if: :saved_change_to_style_string?

  def rewrite_file_css
    File.open('/tmp/morvi-custom-style.css', 'w') { |file| file.write(self.style_string) }
    self.style_file = File.open('/tmp/morvi-custom-style.css')
    self.save
  end
end
