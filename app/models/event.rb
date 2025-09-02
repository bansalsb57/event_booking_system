class Event < ApplicationRecord
  belongs_to :organizer, class_name: "User"  # Organizer (User with event_organizer role)
  has_many :tickets, dependent: :destroy
  has_many :bookings, dependent: :destroy

  validates :title, :description, :date, :venue, presence: true
end
