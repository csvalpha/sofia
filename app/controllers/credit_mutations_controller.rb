class CreditMutationsController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  def model_class
    CreditMutation
  end

  def model_includes
    [:user]
  end
end
