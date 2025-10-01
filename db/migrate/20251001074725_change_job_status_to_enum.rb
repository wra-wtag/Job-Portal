class ChangeJobStatusToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :jobs, :status_temp, :integer

    Job.reset_column_information
    Job.find_each do |job|
      case job.status
      when 'draft'
        job.update_column(:status_temp, 0)
      when 'published'
        job.update_column(:status_temp, 1)
      when 'closed'
        job.update_column(:status_temp, 2)
      end
    end
    remove_column :jobs, :status
    rename_column :jobs, :status_temp, :status

    add_index :jobs, :status
  end

  def down
    add_column :jobs, :status_temp, :string

    Job.reset_column_information
    Job.find_each do |job|
      case job.status
      when 0
        job.update_column(:status_temp, 'draft')
      when 1
        job.update_column(:status_temp, 'published')
      when 2
        job.update_column(:status_temp, 'closed')
      end
    end
    remove_column :jobs, :status
    rename_column :jobs, :status_temp, :status

    add_index :jobs, :status
  end
end
