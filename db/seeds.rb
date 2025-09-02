# Clear existing data
Booking.destroy_all
Ticket.destroy_all
Event.destroy_all
User.destroy_all

# Create Users
organizers = User.create!([
  { email: 'organizer1@example.com', password: 'password', name: 'Organizer One', role: 0 },
  { email: 'organizer2@example.com', password: 'password', name: 'Organizer Two', role: 0 }
])

customers = User.create!([
  { email: 'customer1@example.com', password: 'password', name: 'Customer One', role: 1 },
  { email: 'customer2@example.com', password: 'password', name: 'Customer Two', role: 1 },
  { email: 'customer3@example.com', password: 'password', name: 'Customer Three', role: 1 }
])

# Create Events
events = Event.create!([
  { title: 'Music Concert', description: 'Live music concert', date: Time.now + 5.days, venue: 'Stadium A', organizer_id: organizers.first.id },
  { title: 'Tech Conference', description: 'Annual Tech Conference', date: Time.now + 10.days, venue: 'Convention Center', organizer_id: organizers.first.id },
  { title: 'Art Exhibition', description: 'Showcasing local artists', date: Time.now + 15.days, venue: 'Art Gallery', organizer_id: organizers.second.id },
  { title: 'Food Festival', description: 'Taste foods from around the world', date: Time.now + 20.days, venue: 'City Square', organizer_id: organizers.second.id },
  { title: 'Marathon', description: 'Annual city marathon', date: Time.now + 30.days, venue: 'Central Park', organizer_id: organizers.second.id }
])

# Create Tickets
ticket_types = { general: 0, vip: 1, premium: 2 }
events.each do |event|
  Ticket.create!([
    { ticket_type: ticket_types[:general], price: 50.0, quantity_available: 100, event_id: event.id },
    { ticket_type: ticket_types[:vip], price: 100.0, quantity_available: 50, event_id: event.id },
    { ticket_type: ticket_types[:premium], price: 150.0, quantity_available: 25, event_id: event.id }
  ])
end

# Create Bookings
Booking.create!([
  { quantity: 2, customer_id: customers.first.id, event_id: events.first.id, ticket_id: events.first.tickets.first.id },
  { quantity: 1, customer_id: customers.second.id, event_id: events.second.id, ticket_id: events.second.tickets.second.id }
])

puts 'Seeding completed successfully!'
