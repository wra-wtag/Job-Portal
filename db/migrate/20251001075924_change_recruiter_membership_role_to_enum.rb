class ChangeRecruiterMembershipRoleToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :recruiter_memberships, :role_temp, :integer

    RecruiterMembership.reset_column_information
    RecruiterMembership.find_each do |recruiter_membership|
      case recruiter_membership.role
      when 'standard'
        recruiter_membership.update_column(:role_temp, 0)
      when 'manager'
        recruiter_membership.update_column(:role_temp, 1)
      end
    end
    remove_column :recruiter_memberships, :role
    rename_column :recruiter_memberships, :role_temp, :role

    add_index :recruiter_memberships, :role
  end

  def down
    add_column :recruiter_memberships, :role_temp, :string

    RecruiterMembership.reset_column_information
    RecruiterMembership.find_each do |recruiter_membership|
      case recruiter_membership.role
      when 0
        recruiter_membership.update_column(:role_temp, 'standard')
      when 1
        recruiter_membership.update_column(:role_temp, 'manager')
      end
    end
    remove_column :recruiter_memberships, :role
    rename_column :recruiter_memberships, :role_temp, :role

    add_index :recruiter_memberships, :role
  end
end
