class Section < ApplicationRecord
  
  AVAILABLE_NAME = %w(Header Slideshow).freeze
  belongs_to :sectionable, polymorphic: true

  validates :name, uniqueness: { case_sensitive: false }

  def as_json
    return {
      id: id, 
      name: name,
      object: sectionable.as_json
    }
  end
end