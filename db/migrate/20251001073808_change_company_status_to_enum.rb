class ChangeCompanyStatusToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :companies, :status_temp, :integer, default: 0, null: false

    Company.reset_column_information

    Company.find_each do |company|
      company_status = case company.read_attribute(:status)
      when 'pending' then 0
      when 'approved' then 1
      when 'rejected' then 2
      else 0
      end
      company.update_column(:status_temp, company_status)
    end

    remove_column :companies, :status
    rename_column :companies, :status_temp, :status

    add_index :companies, :status
  end

  def down
    add_column :companies, :status_temp, :string, default: 'pending', null: false

    Company.reset_column_information

    Company.find_each do |company|
      company_status = case company.read_attribute(:status)
      when 0 then 'pending'
      when 1 then 'approved'
      when 2 then 'rejected'
      else 'pending'
      end
      company.update_column(:status_temp, company_status)
    end

    remove_column :companies, :status
    rename_column :companies, :status_temp, :status

    add_index :companies, :status
  end
end
