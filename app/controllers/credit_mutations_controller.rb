class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def create; end

  def model_includes
    [:user]
  end
end
