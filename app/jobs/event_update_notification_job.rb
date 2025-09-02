class EventUpdateNotificationJob < ApplicationJob
  queue_as :mailers

  def perform(event_id)
    event = Event.find(event_id)
    event.bookings.each do |booking|
      puts "Notifying #{booking.customer.email} about updates to event ##{event.id}, ##{event.title}"
    end
  end
end
