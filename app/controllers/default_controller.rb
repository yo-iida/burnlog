class DefaultController < ApplicationController
  def index
    if session[:access_token]
      token = session[:access_token]
      client = Octokit::Client.new access_token: token
      @repos = client.repos
    else
      redirect_to new_user_session_path
    end
  end
end
