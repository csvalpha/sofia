class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @credit_mutations = CreditMutation.includes(model_includes)
    authorize @credit_mutations
  end

  def show
    @credit_mutation = CreditMutation.includes(model_includes).find(params[:id])

    authorize @credit_mutation
  end


  def create; end

  def model_includes
    [:user]
  end
end
