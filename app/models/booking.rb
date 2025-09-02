class Booking < ApplicationRecord
  belongs_to :customer, class_name: "User", foreign_key: :customer_id
  belongs_to :event
  belongs_to :ticket

  validates :quantity, presence: true, numericality: { greater_than: 0 }
end
