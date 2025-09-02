class Ticket < ApplicationRecord
  belongs_to :event
  has_many :bookings, dependent: :destroy
 
  # enum :ticket_type, { general: 0, vip: 1, premium: 2 }
  enum :ticket_type, %i[general vip premium]

  validates :ticket_type, :price, :quantity_available, presence: true
  
end
