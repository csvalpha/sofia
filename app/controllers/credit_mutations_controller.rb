class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @credit_mutations = CreditMutation.includes(model_includes)
    authorize @credit_mutations
  end

  def create; end

  def model_includes
    [:user]
  end
end
