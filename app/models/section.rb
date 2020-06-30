# == Schema Information
#
# Table name: sections
#
#  id               :bigint           not null, primary key
#  online_store_id  :integer
#  name             :string(255)
#  sectionable_id   :bigint
#  sectionable_type :string(255)
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Section < ApplicationRecord
  
  AVAILABLE_NAME = %w(Header Slideshow).freeze
  belongs_to :sectionable, polymorphic: true

  def as_json
    return {
      id: id, 
      name: name,
      object: sectionable.as_json
    }
  end
end
