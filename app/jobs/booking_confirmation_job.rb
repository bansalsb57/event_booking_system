class BookingConfirmationJob < ApplicationJob
  queue_as :mailers

  def perform(booking_id)
    booking = Booking.find(booking_id)
    # debugger
    puts "Email confirmation for booking ##{booking.id} will be sent to #{booking.customer.email}"
  end
end
