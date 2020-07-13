# == Schema Information
#
# Table name: online_stores
#
#  id           :bigint           not null, primary key
#  community_id :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_online_stores_on_community_id  (community_id)
#

class OnlineStore < ApplicationRecord
  belongs_to :community
  has_many :sections, -> { includes :sectionable}, dependent: :destroy

  DEFAULT_SECTIONS = %w(header slideshow highlight_banner)
  # has_many :sectionable, through: :sections, source_type: 'Sectionable'
  # has_one :slideshow, through: :header
  # has_one :highlight_banner, dependent: :destroy
  # def header 
  #   sections.where(sectionable_type: 'Header').last&.sectionable
  # end

  # def slideshow

  # end

    # class << self
      
    # end
  DEFAULT_SECTIONS.each do |model|
    define_method model do 
      sections.where(sectionable_type: model.camelize).last&.sectionable
    end
  end

  def extra_sections
    sections.where.not(sectionable_type: DEFAULT_SECTIONS.map(&:camelize))
  end
end
