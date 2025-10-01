class ChangeRecruiterMembershipStatusToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :recruiter_memberships, :status_temp, :integer

    RecruiterMembership.reset_column_information
    RecruiterMembership.find_each do |recruiter_membership|
      case recruiter_membership.status
      when 'pending'
        recruiter_membership.update_column(:status_temp, 0)
      when 'approved'
        recruiter_membership.update_column(:status_temp, 1)
      when 'rejected'
        recruiter_membership.update_column(:status_temp, 2)
      end
    end
    remove_column :recruiter_memberships, :status
    rename_column :recruiter_memberships, :status_temp, :status

    add_index :recruiter_memberships, :status
  end

  def down
    add_column :recruiter_memberships, :status_temp, :string

    RecruiterMembership.reset_column_information
    RecruiterMembership.find_each do |recruiter_membership|
      case recruiter_membership.status
      when 0
        recruiter_membership.update_column(:status_temp, 'pending')
      when 1
        recruiter_membership.update_column(:status_temp, 'approved')
      when 2
        recruiter_membership.update_column(:status_temp, 'rejected')
      end
    end
    remove_column :recruiter_memberships, :status
    rename_column :recruiter_memberships, :status_temp, :status

    add_index :recruiter_memberships, :status
  end
end
