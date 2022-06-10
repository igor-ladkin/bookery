class ApplicationController < ActionController::Base
  before_action :hijack_user_session
  before_action :set_current_user

  attr_accessor :current_user

  private

  def hijack_user_session
    if params[:u].present?
      session[:user_name] = params[:u]
    end
  end

  def set_current_user
    self.current_user = User.find_by(name: session[:user_name]) || User.first
  end
end
