class SudoController < ApplicationController
  def exit
    reset_sudo_session!

    flash[:success] = 'Penningmeester modus verlaten'

    redirect_to root_path
  end
end
