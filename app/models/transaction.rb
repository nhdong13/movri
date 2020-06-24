# == Schema Information
#
# Table name: transactions
#
#  id                                :integer          not null, primary key
#  starter_id                        :string(255)
#  starter_uuid                      :binary(16)
#  conversation_id                   :integer
#  automatic_confirmation_after_days :string(255)
#  community_id                      :string(255)
#  community_uuid                    :string(255)
#  created_at                        :datetime         not null
#  updated_at                        :datetime         not null
#  starter_skipped_feedback          :boolean          default(FALSE)
#  author_skipped_feedback           :boolean          default(FALSE)
#  last_transition_at                :datetime
#  current_state                     :string(255)
#  payment_gateway                   :string(255)      default("none"), not null
#  unit_type                         :string(32)
#  unit_price_cents                  :integer
#  unit_price_currency               :string(8)
#  unit_tr_key                       :string(64)
#  unit_selector_tr_key              :string(64)
#  payment_process                   :string(31)       default("none")
#  delivery_method                   :string(31)       default("none")
#  shipping_price_cents              :integer
#  availability                      :string(32)       default("none")
#  booking_uuid                      :binary(16)
#  deleted                           :boolean          default(FALSE)
#  uuid                              :binary(16)       not null
#  instructions_from_seller          :text(65535)
#  promo_code_id                     :integer
#  total_price_cents                 :integer
#  tax_cents                         :integer
#  promo_code_discount_cents         :integer
#
# Indexes
#
#  community_starter_state                   (community_id,starter_id,current_state)
#  index_transactions_on_community_id        (community_id)
#  index_transactions_on_conversation_id     (conversation_id)
#  index_transactions_on_deleted             (deleted)
#  index_transactions_on_last_transition_at  (last_transition_at)
#  index_transactions_on_starter_id          (starter_id)
#  transactions_on_cid_and_deleted           (community_id,deleted)
#

class Transaction < ApplicationRecord
  include ExportTransaction

  attr_accessor :contract_agreed

  belongs_to :community
  belongs_to :promo_code
  has_and_belongs_to_many :listings
  has_many :transaction_transitions, dependent: :destroy, foreign_key: :transaction_id, inverse_of: :tx
  has_one :booking, dependent: :destroy
  has_many :transaction_addresses, dependent: :destroy
  belongs_to :starter, class_name: "Person", foreign_key: :starter_id, inverse_of: :starter_transactions
  belongs_to :conversation
  has_many :testimonials, dependent: :destroy
  belongs_to :listing_author, class_name: 'Person'
  has_many :stripe_payments, dependent: :destroy
  has_many :transaction_items, dependent: :destroy
  has_one :shipper, dependent: :destroy

  delegate :author, to: :listing
  delegate :title, to: :listing, prefix: true

  accepts_nested_attributes_for :booking

  # validates :payment_gateway, presence: true, on: :create
  # validates :community_uuid, presence: true, on: :create
  # validates :unit_type, inclusion: ["hour", "day", "night", "week", "month", "custom", "unit", nil, :hour, :day, :night, :week, :month, :custom, :unit], on: :create
  # validates :availability, inclusion: ["none", "booking", :none, :booking], on: :create
  # validates :payment_process, inclusion: [:none, :postpay, :preauthorize], on: :create
  # validates :payment_gateway, inclusion: [:paypal, :checkout, :braintree, :stripe, :none], on: :create
  # validates :automatic_confirmation_after_days, numericality: {only_integer: true}, on: :create
  validates :delivery_method, inclusion: ["none", "shipping", "pickup", :none, :shipping, :pickup], on: :create

  # monetize :unit_price_cents, with_model_currency: :unit_price_currency
  monetize :shipping_price_cents, allow_nil: true, with_model_currency: :unit_price_currency

  scope :exist, -> { where(deleted: false) }
  scope :for_person, -> (person){
    joins(:listing)
    .where("listings.author_id = ? OR starter_id = ?", person.id, person.id)
  }
  scope :availability_blocking, -> do
    where(current_state: ['payment_intent_requires_action', 'preauthorized', 'paid', 'confirmed', 'canceled'])
  end
  scope :non_free, -> { where('current_state <> ?', ['free']) }
  scope :by_community, -> (community_id) { where(community_id: community_id) }
  scope :with_payment_conversation, -> {
    left_outer_joins(:conversation).merge(Conversation.payment)
  }
  scope :with_payment_conversation_latest, -> (sort_direction) {
    with_payment_conversation.order(Arel.sql(
      "GREATEST(COALESCE(transactions.last_transition_at, 0),
        COALESCE(conversations.last_message_at, 0)) #{sort_direction}"))
  }
  scope :for_csv_export, -> {
    includes(:starter, :booking, :testimonials, :transaction_transitions, :conversation => [{:messages => :sender}, :listing, :participants], :listing => :author)
  }
  scope :for_testimonials, -> {
    includes(:testimonials, testimonials: [:author, :receiver], listing: :author)
    .where(current_state: ['confirmed', 'canceled'])
  }
  scope :search_by_party_or_listing_title, ->(pattern) {
    joins(:starter, :listing_author)
    .where("listing_title like :pattern
        OR (#{Person.search_by_pattern_sql('people')})
        OR (#{Person.search_by_pattern_sql('listing_authors_transactions')})", pattern: pattern)
  }
  scope :search_for_testimonials, ->(community, pattern) do
    with_testimonial_ids = by_community(community.id)
    .left_outer_joins(testimonials: [:author, :receiver])
    .where("
      testimonials.text like :pattern
      OR #{Person.search_by_pattern_sql('people')}
      OR #{Person.search_by_pattern_sql('receivers_testimonials')}
    ", pattern: pattern).select("`transactions`.`id`")

    for_testimonials.joins(:listing, :starter, :listing_author)
    .where("
      `listings`.`title` like :pattern
      OR #{Person.search_by_pattern_sql('people')}
      OR #{Person.search_by_pattern_sql('listing_authors_transactions')}
      OR `transactions`.`id` IN (#{with_testimonial_ids.to_sql})
      ", pattern: pattern).distinct
  end
  scope :paid_or_confirmed, -> { where(current_state: ['paid', 'confirmed']) }
  scope :skipped_feedback, -> { where('starter_skipped_feedback OR author_skipped_feedback') }

  scope :waiting_feedback, -> {
    where("NOT starter_skipped_feedback AND NOT #{Testimonial.with_tx_starter.select('1').arel.exists.to_sql}
           OR NOT author_skipped_feedback AND NOT #{Testimonial.with_tx_author.select('1').arel.exists.to_sql}")
  }
  scope :fulfilled_orders, -> { where(current_state: "fulfilled")}
  scope :unfulfilled_orders, -> { where(current_state: "unfulfilled")}

  def shipping_address
    transaction_addresses.where(address_type: 0)&.first
  end

  def will_pickup?
    delivery_method == "pickup"
  end

  def will_shipping?
    delivery_method == "shipping"
  end

  def uuid_object
    if self[:uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:uuid])
    end
  end

  def uuid_object=(uuid)
    self.uuid = UUIDUtils.raw(uuid)
  end

  before_create :add_uuid
  def add_uuid
    self.uuid ||= UUIDUtils.create_raw
  end

  def booking_uuid_object
    if self[:booking_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:booking_uuid])
    end
  end

  def booking_uuid_object=(uuid)
    self.booking_uuid = UUIDUtils.raw(uuid)
  end

  def community_uuid_object
    if self[:community_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:community_uuid])
    end
  end

  def starter_uuid_object
    if self[:starter_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:starter_uuid])
    end
  end

  def listing_author_uuid_object
    if self[:listing_author_uuid].nil?
      nil
    else
      UUIDUtils.parse_raw(self[:listing_author_uuid])
    end
  end

  def starter_uuid=(value)
    write_attribute(:starter_uuid, UUIDUtils::RAW.call(value))
  end

  def community_uuid=(value)
    write_attribute(:community_uuid, UUIDUtils::RAW.call(value))
  end

  def booking_uuid=(value)
    write_attribute(:booking_uuid, UUIDUtils::RAW.call(value))
  end

  def status
    current_state
  end

  def has_feedback_from?(person)
    if author == person
      testimonial_from_author.present?
    else
      testimonial_from_starter.present?
    end
  end

  def feedback_skipped_by?(person)
    if author == person
      author_skipped_feedback?
    else
      starter_skipped_feedback?
    end
  end

  def testimonial_from_author
    testimonials.find { |testimonial| testimonial.author_id == author.id }
  end

  def testimonial_from_starter
    testimonials.find { |testimonial| testimonial.author_id == starter.id }
  end

  # TODO This assumes that author is seller (which is true for all offers, sell, give, rent, etc.)
  # Change it so that it looks for TransactionProcess.author_is_seller
  def seller
    author
  end

  # TODO This assumes that author is seller (which is true for all offers, sell, give, rent, etc.)
  # Change it so that it looks for TransactionProcess.author_is_seller
  def buyer
    starter
  end

  def participations
    [author, starter]
  end

  def payer
    starter
  end

  def payment_receiver
    author
  end

  def with_type(&block)
    block.call(:listing_conversation)
  end

  def latest_activity
    (transaction_transitions + conversation.messages).max
  end

  # Give person (starter or listing author) and get back the other
  #
  # Note: I'm not sure whether we want to have this method or not but at least it makes refactoring easier.
  def other_party(person)
    person == starter ? listing.author : starter
  end

  def unit_type
    Maybe(read_attribute(:unit_type)).to_sym.or_else(nil)
  end

  def item_total
    unit_price * listing_quantity
  end

  def payment_gateway
    read_attribute(:payment_gateway)&.to_sym
  end

  def payment_process
    read_attribute(:payment_process)&.to_sym
  end

  def commission
    [(item_total * (commission_from_seller / 100.0) unless commission_from_seller.nil?),
     (minimum_commission unless minimum_commission.nil? || minimum_commission.zero?),
     Money.new(0, item_total.currency)]
      .compact
      .max
  end

  def buyer_commission
    [(item_total * (commission_from_buyer / 100.0) unless commission_from_buyer.nil?),
     (minimum_buyer_fee unless minimum_buyer_fee.nil? || minimum_buyer_fee.zero?),
     Money.new(0, item_total.currency)]
      .compact
      .max
  end

  def waiting_testimonial_from?(person_id)
    if starter_id == person_id && starter_skipped_feedback
      false
    elsif listing_author_id == person_id && author_skipped_feedback
      false
    else
      testimonials.detect{|t| t.author_id == person_id}.nil?
    end
  end

  def mark_as_seen_by_current(person_id)
    self.conversation
      .participations
      .where("person_id = '#{person_id}'")
      .update_all(is_read: true) # rubocop:disable Rails/SkipsModelValidations
  end

  def payment_total
    unit_price       = self.unit_price || 0
    quantity         = self.listing_quantity || 1
    shipping_price   = self.shipping_price || 0
    (unit_price * quantity) + shipping_price + buyer_commission
  end

  def total_quantity
    quantity = 0
    return quantity unless transaction_items.any?
    transaction_items.map { |item| quantity += item.quantity}
    quantity
  end

  def paid?
    payment_process == :paid
  end

  def fulfilled?
    current_state == "fulfilled"
  end

  def shipping_method_label
    "#{shipper.service_name} #{shipper.amount} #{shipper.currency}"
  end

  def completed?
    current_state == "paid"
  end

  def is_overweight?
    weight = 0
    transaction_items.each do |item|
      packing_dimension = item.listing.packing_dimensions.first
      weight += (packing_dimension.weight) * item.quantity
    end
    weight > LIMIT_WEIGHT_OF_FEDEX_SERVICE
  end
end
