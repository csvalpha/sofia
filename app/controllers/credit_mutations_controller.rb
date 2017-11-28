class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @mutations = CreditMutation.includes(model_includes)
    authorize @mutations
  end

  def create; end

  def update; end

  def destroy; end

  def model_includes
    [:user]
  end
end
