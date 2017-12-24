class CreditMutationsController < ApplicationController
  def create; end

  def model_includes
    [:user]
  end
end
