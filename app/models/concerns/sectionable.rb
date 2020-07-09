require 'active_support/concern'

module Sectionable
  extend ActiveSupport::Concern

  def section
    Section.find_by(sectionable_id: self.id, sectionable_type: self.class.name)
  end
end