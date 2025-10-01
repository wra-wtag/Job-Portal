class ChangeJobEmploymentTypeToEnum < ActiveRecord::Migration[8.0]
  def up
    add_column :jobs, :employment_type_temp, :integer

    Job.reset_column_information
    Job.find_each do |job|
      case job.employment_type
      when 'full_time'
        job.update_column(:employment_type_temp, 0)
      when 'part_time'
        job.update_column(:employment_type_temp, 1)
      when 'contract'
        job.update_column(:employment_type_temp, 2)
      when 'internship'
        job.update_column(:employment_type_temp, 3)
      when 'temporary'
        job.update_column(:employment_type_temp, 4)
      end
    end
    remove_column :jobs, :employment_type
    rename_column :jobs, :employment_type_temp, :employment_type

    add_index :jobs, :employment_type
  end

  def down
    add_column :jobs, :employment_type_temp, :string

    Job.reset_column_information
    Job.find_each do |job|
      case job.employment_type
      when 0
        job.update_column(:employment_type_temp, 'full_time')
      when 1
        job.update_column(:employment_type_temp, 'part_time')
      when 2
        job.update_column(:employment_type_temp, 'contract')
      when 3
        job.update_column(:employment_type_temp, 'internship')
      when 4
        job.update_column(:employment_type_temp, 'temporary')
      end
    end
    remove_column :jobs, :employment_type
    rename_column :jobs, :employment_type_temp, :employment_type

    add_index :jobs, :employment_type
  end
end
