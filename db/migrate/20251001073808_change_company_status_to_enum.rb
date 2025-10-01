class ChangeCompanyStatusToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :companies, :status_temp, :integer
    
    Company.reset_column_information
    Company.find_each do |company|
      case company.status
      when 'pending'
        company.update_column(:status_temp, 0)
      when 'approved'
        company.update_column(:status_temp, 1)
      when 'rejected'
        company.update_column(:status_temp, 2)
      end
    end
    remove_column :companies, :status
    rename_column :companies, :status_temp, :status
    
    add_index :companies, :status
  end

  def down
    add_column :companies, :status_temp, :string
    
    Application.reset_column_information
    Application.find_each do |application|
      case application.status
      when 0
        application.update_column(:status_temp, 'pending')
      when 1
        application.update_column(:status_temp, 'approved')
      when 2
        application.update_column(:status_temp, 'rejected')
      end
    end
    remove_column :companies, :status
    rename_column :companies, :status_temp, :status
    
    add_index :companies, :status
  end
end
