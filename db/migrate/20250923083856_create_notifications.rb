class CreateNotifications < ActiveRecord::Migration[8.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: true
      t.string :kind, null: false
      t.string :title, null: false # new_job_application, application_update, job_recommendation
      t.text :content
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, :kind
    add_index :notifications, :read_at
  end
end
