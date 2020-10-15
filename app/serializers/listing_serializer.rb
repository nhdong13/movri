# == Schema Information
#
# Table name: listings
#
#  id                              :integer          not null, primary key
#  uuid                            :binary(16)       not null
#  community_id                    :integer          not null
#  author_id                       :string(255)
#  category_old                    :string(255)
#  title                           :string(255)
#  times_viewed                    :integer          default(0)
#  language                        :string(255)
#  created_at                      :datetime
#  updates_email_at                :datetime
#  updated_at                      :datetime
#  last_modified                   :datetime
#  sort_date                       :datetime
#  listing_type_old                :string(255)
#  description                     :text(65535)
#  origin                          :string(255)
#  destination                     :string(255)
#  valid_until                     :datetime
#  delta                           :boolean          default(TRUE), not null
#  open                            :boolean          default(TRUE)
#  share_type_old                  :string(255)
#  privacy                         :string(255)      default("private")
#  comments_count                  :integer          default(0)
#  subcategory_old                 :string(255)
#  old_category_id                 :integer
#  category_id                     :integer
#  share_type_id                   :integer
#  listing_shape_id                :integer
#  transaction_process_id          :integer
#  shape_name_tr_key               :string(255)
#  action_button_tr_key            :string(255)
#  price_cents                     :integer
#  currency                        :string(255)
#  quantity                        :string(255)
#  unit_type                       :string(32)
#  quantity_selector               :string(32)
#  unit_tr_key                     :string(64)
#  unit_selector_tr_key            :string(64)
#  deleted                         :boolean          default(FALSE)
#  require_shipping_address        :boolean          default(FALSE)
#  pickup_enabled                  :boolean          default(FALSE)
#  shipping_price_cents            :integer
#  shipping_price_additional_cents :integer
#  availability                    :string(32)       default("none")
#  per_hour_ready                  :boolean          default(FALSE)
#  state                           :string(255)      default("approved")
#  spec                            :text(65535)
#  overview                        :text(65535)
#  q_a                             :text(65535)
#  in_the_box                      :text(65535)
#  not_in_the_box                  :text(65535)
#  key_feature                     :text(65535)
#  available_quantity              :integer          default(0)
#  sku                             :string(255)
#  barcode                         :string(255)
#  track_quantity                  :boolean
#  contiunue_sell                  :boolean
#  user_manual                     :string(255)
#  weight                          :integer
#  user_manual_file_name           :string(255)
#  user_manual_content_type        :string(255)
#  user_manual_file_size           :integer
#  user_manual_updated_at          :datetime
#  weight_type                     :integer
#  video                           :string(255)
#  tags                            :string(255)
#  manually_blocked_dates          :text(65535)
#  replacement_cents_fee           :integer          default(0)
#  brand                           :string(255)
#  number_of_rent                  :integer          default(0)
#  listing_type                    :integer          default(0)
#  mount                           :string(255)
#  lens_type                       :string(255)
#  compatibility                   :string(255)
#  url                             :string(255)
#
# Indexes
#
#  community_author_deleted            (community_id,author_id,deleted)
#  index_listings_on_category_id       (old_category_id)
#  index_listings_on_community_id      (community_id)
#  index_listings_on_listing_shape_id  (listing_shape_id)
#  index_listings_on_new_category_id   (category_id)
#  index_listings_on_open              (open)
#  index_listings_on_state             (state)
#  index_listings_on_uuid              (uuid) UNIQUE
#  index_on_author_id_and_deleted      (author_id,deleted)
#  listings_homepage_query             (community_id,open,state,deleted,valid_until,sort_date)
#  listings_updates_email              (community_id,open,state,deleted,valid_until,updates_email_at,created_at)
#  person_listings                     (community_id,author_id)
#

class ListingSerializer < ActiveModel::Serializer
  attributes :id, :title
end
