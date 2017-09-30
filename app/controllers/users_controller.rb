class UsersController < ApplicationController
  before_action :set_model, only: %i[show update destroy]

  def model_class
    User
  end

  def model_includes
    [:orders]
  end
end
