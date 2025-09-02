class Api::V1::BookingsController < ApplicationController
  before_action :authorize_customer!, only: [:create]

  def index
    bookings = current_user&.bookings&.includes(:event, :ticket)
    if bookings.present?
      render json: bookings, status: :ok
    else
      render json: { message: 'Oppss, No Bookings' }, status: :ok
    end
  end

  def create
    ticket = Ticket.find_by(id: params[:booking][:ticket_id])
    event = Event.find_by(id: params[:booking][:event_id])
    
    return render json: { error: 'Invalid ticket or event' }, status: :not_found unless ticket && event
    
    if ticket.quantity_available < params[:booking][:quantity].to_i
      return render json: { error: 'Not enough tickets available' }, status: :unprocessable_entity
    end
    
    booking = current_user.bookings.build(event: event, ticket: ticket, quantity: params[:booking][:quantity])

    if booking.save
      ticket.update(quantity_available: ticket.quantity_available - params[:booking][:quantity].to_i)
      BookingConfirmationJob.perform_later(booking.id)
      render json: { message: 'Booking successful', booking: booking }, status: :created
    else
      render json: { error: booking.errors.full_messages }, status: :unprocessable_entity
    end
  end

  ## 
  def wait_list
    if booking
      booking.update(wait_list: true)
    end
  end

  private

  def booking_params
    params.require(:booking).permit(:event_id, :ticket_id, :quantity)
  end
end
