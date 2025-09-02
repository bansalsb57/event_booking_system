class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :validatable

  # Associations
  has_many :events, foreign_key: :organizer_id, dependent: :destroy  # Event Organizer's events
  has_many :bookings, foreign_key: :customer_id, dependent: :destroy  # Customer's bookings

  enum :role, %i[event_organizer customer]

  validates :name, :role, presence: true
end
