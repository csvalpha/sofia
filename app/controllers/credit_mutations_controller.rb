class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    @credit_mutations = CreditMutation.includes(model_includes)
    authorize @credit_mutations

    @new_mutation = CreditMutation.new
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @mutation = CreditMutation.new(permitted_attributes.merge(created_by: current_user))
    authorize @mutation

    respond_to do |format|
      if @mutation.save
        format.html { redirect_to request.referer, success: 'Successfully created mutation' }
        format.json { render json: @mutation, include: { user: { methods: :credit } } }

      else
        format.html { redirect_to request.referer, error: @mutation.errors.full_messages.join(', ') }
        format.json { render json: @mutation.errors, status: :unprocessable_entity }
      end
    end
  end

  def model_includes
    %i[user activity created_by]
  end

  def permitted_attributes
    params.require(:credit_mutation).permit(%i[description amount user_id activity_id])
  end
end
