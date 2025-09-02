class Api::V1::TicketsController < ApplicationController
  before_action :authorize_event_organizer!, only: [:create]

  def index
    event = Event.find(params[:event_id])
    tickets = event.tickets
    render json: tickets, status: :ok
  end

  def create
    event = current_user.events.find(params[:event_id])
    params[:ticket][:ticket_type] = params[:ticket][:ticket_type].downcase 
    ticket = event.tickets.build(ticket_params) 
    
    if ticket.save
      render json: { message: 'Ticket created successfully', ticket: ticket }, status: :created
    else
      render json: { error: ticket.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def ticket_params
    params.require(:ticket).permit(:ticket_type, :price, :quantity_available)
  end
end
