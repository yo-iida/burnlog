class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def github
    @user = User.find_or_create_by(user_params)

    if @user.persisted?
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
    p = request.env["omniauth.auth"].slice(:info, :provider, :uid).to_h
    {
      username: p["info"]["nickname"],
      email: p["info"]["email"],
      provider: p["provider"],
      uid: p["uid"]
    }
  end
end
