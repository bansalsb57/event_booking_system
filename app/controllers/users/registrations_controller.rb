# frozen_string_literal: true

class Users::RegistrationsController < Devise::RegistrationsController
  respond_to :json

  private

  def sign_up_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role)
  end

  def respond_with(resource, _opts = {})
    if resource.persisted?
      render json: { status: 'success', message: 'Signed up successfully', user: resource }, status: :created
    else
      render json: { status: 'error', message: resource.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
