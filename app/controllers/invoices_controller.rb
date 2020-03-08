class InvoicesController < ApplicationController
  before_action :authenticate_user!
  after_action :verify_authorized

  def index
    authorize Invoice

    @invoices = Invoice.all
  end
end
