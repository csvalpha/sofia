class CreditMutationsController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize CreditMutation

    @credit_mutations = policy_scope(CreditMutation.includes(model_includes)
                                      .order(created_at: :desc)
                                      .page(params[:page]))

    @new_mutation = CreditMutation.new
  end

  def create # rubocop:disable Metrics/MethodLength, Metrics/AbcSize
    @mutation = CreditMutation.new(credit_mutation_params.merge(created_by: current_user))
    authorize @mutation

    respond_to do |format|
      if @mutation.save
        NewCreditMutationNotificationJob.perform_later(@mutation) unless Rails.env.local?
        format.html { redirect_to which_redirect?, flash: { success: 'Inleg of mutatie aangemaakt' } }
        format.json do
          render json: @mutation, include: { user: { methods: User.orderscreen_json_includes } }
        end

      else
        format.html { redirect_to which_redirect?, flash: { error: @mutation.errors.full_messages.join(', ') } }
        format.json { render json: @mutation.errors, status: :unprocessable_content }
      end
    end
  end

  def which_redirect?
    request.referer || @mutation.user
  end

  def model_includes
    %i[user activity created_by]
  end

  def credit_mutation_params
    params.require(:credit_mutation).permit(policy(CreditMutation).permitted_attributes)
  end
end
