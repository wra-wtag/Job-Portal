class AddDefaultStatusToJobs < ActiveRecord::Migration[8.0]
  def change
    change_column_default :jobs, :status, from: nil, to: 0
    change_column_null :jobs, :status, false, 0
  end
end
