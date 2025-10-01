class AddDefaultStatusToApplications < ActiveRecord::Migration[8.0]
  def change
    change_column_default :applications, :status, from: nil, to: 0
    change_column_null :applications, :status, false, 0
  end
end
