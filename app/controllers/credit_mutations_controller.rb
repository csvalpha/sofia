class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @credit_mutations = CreditMutation.includes(model_includes)
    authorize @credit_mutations

    @new_mutation = CreditMutation.new
  end

  def create
    @mutation = CreditMutation.new(permitted_attributes.merge(created_by: current_user))
    authorize @mutation

    respond_to do |format|
      format.html do
        if @mutation.save
          flash[:success] = 'Successfully created mutation'
        else
          flash[:error] = @mutation.errors.full_messages.join(', ')
        end

        redirect_to request.referer
      end

      format.json do
        if @mutation.save
          render json: @mutation, include: { user: { methods: :credit } }
        else
          render json: @mutation.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def model_includes
    %i[user activity]
  end

  def permitted_attributes
    params.require(:credit_mutation).permit(%i[description amount user_id activity_id])
  end
end
