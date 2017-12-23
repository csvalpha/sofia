class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @credit_mutations = CreditMutation.includes(model_includes)
    authorize @credit_mutations

    @edit_mutation = CreditMutation.new
  end

  def show
    @credit_mutation = CreditMutation.includes(model_includes).find(params[:id])

    authorize @credit_mutation
  end

  def create
    @mutation = CreditMutation.new(permitted_attributes)
    authorize @mutation

    if @mutation.save
      flash[:success] = 'Successfully created mutation'
    else
      flash[:error] = @mutation.errors.full_messages.join(', ')
    end

    redirect_to request.referrer
  end


  def model_includes
    [:user]
  end

  def permitted_attributes
    params.require(:credit_mutation).permit(%i[description amount user_id activity_id])
  end
end
