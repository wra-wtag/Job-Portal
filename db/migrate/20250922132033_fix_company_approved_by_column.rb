class FixCompanyApprovedByColumn < ActiveRecord::Migration[8.0]
  def change
    change_column_null :companies, :approved_by_id, true
  end
end
