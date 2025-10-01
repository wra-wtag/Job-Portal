class AddDefaultStatusToCompanies < ActiveRecord::Migration[8.0]
  def change
    change_column_default :companies, :status, from: nil, to: 0
    change_column_null :companies, :status, false, 0
  end
end
