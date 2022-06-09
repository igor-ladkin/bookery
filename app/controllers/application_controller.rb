class ApplicationController < ActionController::Base
  before_action :set_current_user

  attr_accessor :current_user

  private

  def set_current_user
    self.current_user = User.first
  end
end
