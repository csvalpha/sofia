class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @credit_mutations = CreditMutation.includes(model_includes)
    authorize @credit_mutations

    @new_mutation = CreditMutation.new
  end

  def create
    @mutation = CreditMutation.new(permitted_attributes.merge(author: current_user))
    authorize @mutation

    if @mutation.save
      flash[:success] = 'Successfully created mutation'
    else
      flash[:error] = @mutation.errors.full_messages.join(', ')
    end

    redirect_to request.referer
  end

  def model_includes
    [:user]
  end

  def permitted_attributes
    params.require(:credit_mutation).permit(%i[description amount user_id activity_id])
  end
end
