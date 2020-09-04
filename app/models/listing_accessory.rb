# == Schema Information
#
# Table name: listing_accessories
#
#  id                       :bigint           not null, primary key
#  brand                    :string(255)
#  mount                    :string(255)
#  lens_type                :string(255)
#  item_type                :integer          default("lens")
#  camera_type              :string(255)
#  camcorder_type           :string(255)
#  sensor_size              :string(255)
#  action_cam_compatibility :string(255)
#  compatibility            :string(255)
#  lighting_type            :string(255)
#  accessory_type           :string(255)
#  capacity                 :string(255)
#  memory_type              :string(255)
#  read_transfer_speed      :string(255)
#  bus_speed                :string(255)
#  power_compatibility      :string(255)
#  power_type               :string(255)
#  support_type             :string(255)
#  head_type                :string(255)
#  quick_release_system     :string(255)
#  color_temperature        :string(255)
#  filter_size              :string(255)
#  filter_style             :string(255)
#  filter_type              :string(255)
#  audio_type               :string(255)
#  monitoring_type          :string(255)
#  camera_support_type      :string(255)
#  cable_type               :string(255)
#  listing_id               :integer
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class ListingAccessory < ApplicationRecord
  belongs_to :listing
  enum item_type: [
    'lens',
    'mirrorless',
    'flashes',
    'memory',
    'power',
    'camera_support',
    'accessory',
    'tripods',
    'lighting',
    'drone',
    'audio',
    'monitoring',
    'stabilizers',
    'switcher',
    'camera'
  ]

  after_save { listing.touch }
end
