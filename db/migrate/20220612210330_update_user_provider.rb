class UpdateUserProvider < ActiveRecord::Migration[6.1]
  def up
    User.where(provider: 'banana_oauth2').update(provider: 'amber_oauth2')
  end

  def down
    User.where(provider: 'amber_oauth2').update(provider: 'banana_oauth2')
  end
end
