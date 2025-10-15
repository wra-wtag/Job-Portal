class ChangeUserRoleToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :users, :role_temp, :integer

    User.reset_column_information
    User.find_each do |user|
      case user.role
      when 'job_seeker'
        user.update_column(:role_temp, 0)
      when 'recruiter'
        user.update_column(:role_temp, 1)
      when 'admin'
        user.update_column(:role_temp, 2)
      end
    end
    remove_column :users, :role
    rename_column :users, :role_temp, :role

    add_index :users, :role
  end

  def down
    add_column :users, :role_temp, :string

    User.reset_column_information
    User.find_each do |user|
      case user.role
      when 0
        user.update_column(:role_temp, 'job_seeker')
      when 1
        user.update_column(:role_temp, 'recruiter')
      when 2
        user.update_column(:role_temp, 'admin')
      end
    end
    remove_column :users, :role
    rename_column :users, :role_temp, :role

    add_index :users, :role
  end
end
