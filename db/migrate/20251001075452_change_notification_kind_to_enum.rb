class ChangeNotificationKindToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :notifications, :kind_temp, :integer

    Notification.reset_column_information
    Notification.find_each do |notification|
      case notification.kind
      when 'new_job_application'
        notification.update_column(:kind_temp, 0)
      when 'application_update'
        notification.update_column(:kind_temp, 1)
      when 'job_recommendation'
        notification.update_column(:kind_temp, 2)
      when 'system_announcement'
        notification.update_column(:kind_temp, 3)
      when 'recruiter_approved'
        notification.update_column(:kind_temp, 4)
      when 'recruiter_rejected'
        notification.update_column(:kind_temp, 5)
      when 'admin_approved_recruiter'
        notification.update_column(:kind_temp, 6)
      end
    end

    remove_column :notifications, :kind
    rename_column :notifications, :kind_temp, :kind

    add_index :notifications, :kind
  end

  def down
    add_column :notifications, :kind_temp, :string

    Notification.reset_column_information
    Notification.find_each do |notification|
      case notification.kind
      when 0
        notification.update_column(:kind_temp, 'new_job_application')
      when 1
        notification.update_column(:kind_temp, 'application_update')
      when 2
        notification.update_column(:kind_temp, 'job_recommendation')
      when 3
        notification.update_column(:kind_temp, 'system_announcement')
      when 4
        notification.update_column(:kind_temp, 'recruiter_approved')
      when 5
        notification.update_column(:kind_temp, 'recruiter_rejected')
      when 6
        notification.update_column(:kind_temp, 'admin_approved_recruiter')
      end
    end

    remove_column :notifications, :kind
    rename_column :notifications, :kind_temp, :kind

    add_index :notifications, :kind
  end
end
