class AddDefaultStatusToRecruiterMemberships < ActiveRecord::Migration[8.0]
  def change
    change_column_default :recruiter_memberships, :status, from: nil, to: 0
    change_column_null :recruiter_memberships, :status, false, 0
  end
end
