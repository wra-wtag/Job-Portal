class ChangeApplicationStatusToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :applications, :status_temp, :integer

    Application.reset_column_information
    Application.find_each do |application|
      case application.status
      when 'applied'
        application.update_column(:status_temp, 0)
      when 'viewed'
        application.update_column(:status_temp, 1)
      when 'shortlisted'
        application.update_column(:status_temp, 2)
      when 'rejected'
        application.update_column(:status_temp, 3)
      when 'hired'
        application.update_column(:status_temp, 4)
      when 'withdrawn'
        application.update_column(:status_temp, 5)
      end
    end
    remove_column :applications, :status
    rename_column :applications, :status_temp, :status

    add_index :applications, :status
  end

  def down
    add_column :applications, :status_temp, :string

    Application.reset_column_information
    Application.find_each do |application|
      case application.status
      when 0
        application.update_column(:status_temp, 'applied')
      when 1
        application.update_column(:status_temp, 'viewed')
      when 2
        application.update_column(:status_temp, 'shortlisted')
      when 3
        application.update_column(:status_temp, 'rejected')
      when 4
        application.update_column(:status_temp, 'hired')
      when 5
        application.update_column(:status_temp, 'withdrawn')
      end
    end
    remove_column :applications, :status
    rename_column :applications, :status_temp, :status

    add_index :applications, :status
  end
end
