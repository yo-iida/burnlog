class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.find_or_create_by(user_params)

    if @user.persisted?
      @user.access_token = request.env["omniauth.auth"]["credentials"]["token"]
      @user.save
      session[:access_token] = @user.access_token
      sign_in_and_redirect @user, :event => :authentication
      set_flash_message(:notice, :success, :kind => "Github") if is_navigational_format?
    else
      session["devise.github_data"] = request.env["omniauth.auth"]
      set_flash_message(:notice, :error, :kind => "Github")
      redirect_to root_path
    end
  end

  private
  def user_params
    {
      username: request.env["omniauth.auth"]["info"]["nickname"],
      email: request.env["omniauth.auth"]["info"]["email"],
      provider: request.env["omniauth.auth"]["provider"],
      uid: request.env["omniauth.auth"]["uid"]
    }
  end
end
