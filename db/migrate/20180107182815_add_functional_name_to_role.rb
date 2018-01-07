class AddFunctionalNameToRole < ActiveRecord::Migration[5.1]
  def up
    remove_index :roles, column: %i[name group_uid]
    add_column :roles, :role_type, :integer

    Role.all.each do |role|
      if role.name == 'Treasurer'
        role.update(role_type: :treasurer)
      elsif role.name == 'Main Bartender'
        role.update(role_type: :main_bartender)
      end
    end

    remove_column :roles, :name
    add_index :roles, %i[role_type group_uid], unique: true
  end

  def down
    remove_index :roles, column: %i[role_type group_uid]
    add_column :roles, :name, :string

    Role.all.each do |role|
      if role.treasurer?
        role.update(name: 'Treasurer')
      elsif role.main_bartender?
        role.update(name: 'Main Bartender')
      end
    end

    remove_column :roles, :role_type
    add_index :roles, %i[name group_uid], unique: true
  end
end
