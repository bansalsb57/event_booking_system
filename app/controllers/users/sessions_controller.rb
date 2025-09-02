class Users::SessionsController < Devise::SessionsController
  respond_to :json
  skip_before_action :verify_signed_out_user, only: :destroy

  def create 
    if params[:user][:email].present? && params[:user][:password].present?
      user = User.find_for_authentication(email: params[:user][:email])
      if user && user.valid_password?(params[:user][:password])
        sign_in(user)
        render json: { message: "#{user.role} logged in successfully", user: user, success: true}, status: :ok
      else
        render json: { error: 'Invalid email or password', success: false }, status: :unauthorized
      end
    else
      render json: { message: 'User not found, please sign up' }, status: :unprocessable_entity
    end
  end 

  def destroy
    if current_user
      sign_out(current_user)
      render json: { message: "#{current_user&.role} Signed out successfully" }, status: :ok
    else
      render json: { error: 'Log out attempt Failed', success: false }, status: :unauthorized
    end
  end
end
