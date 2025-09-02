class ApplicationController < ActionController::API
  # before_action :authenticate_user!

  def authorize_event_organizer!
    render json: { message: 'Access denied. Organizers only.' }, status: :forbidden unless current_user && current_user.event_organizer?
  end

  def authorize_customer!
    render json: { message: 'Access denied. Customers only.' }, status: :forbidden unless current_user && current_user.customer?
  end
end
