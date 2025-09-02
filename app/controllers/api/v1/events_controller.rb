class Api::V1::EventsController < ApplicationController
  before_action :authorize_event_organizer!, only: [:create, :update, :destroy]

  def index
    events = Event.includes(:tickets).all
    render json: events, status: :ok
  end

  def show
    event = Event.includes(:tickets).find(params[:id])
    render json: event, status: :ok
  end

  def create
    event = current_user.events.build(event_params)
    if event.save
      render json: { message: 'Event created successfully', event: event }, status: :created
    else
      render json: { error: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    event = current_user.events.find(params[:id])
    if event.update(event_params)
      EventUpdateNotificationJob.perform_later(event.id)
      render json: { message: 'Event updated successfully', event: event }, status: :ok
    else
      render json: { error: event.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    event = current_user.events.find(params[:id])
    event.destroy
    render json: { message: 'Event deleted successfully' }, status: :ok
  end

  private

  def event_params
    params.require(:event).permit(:title, :description, :date, :venue)
  end
end
