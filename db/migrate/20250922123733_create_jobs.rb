class CreateJobs < ActiveRecord::Migration[8.0]
  def change
    create_table :jobs do |t|
      t.string :title, null: false
      t.references :company, null: false, foreign_key: true
      t.references :posted_by_user, null: false, foreign_key: { to_table: :users }
      t.text :description, null: false
      t.string :employment_type, null: false # full_time, part_time, contract, internship, temporary
      t.decimal :salary_min, precision: 10, scale: 2
      t.decimal :salary_max, precision: 10, scale: 2
      t.string :currency, default: 'USD'
      t.string :status, null: false, default: 'draft' # draft, published, closed
      t.boolean :visibility, default: true
      t.datetime :published_at
      t.datetime :expires_at
      t.datetime :application_deadline
      t.integer :views_count, default: 0
      t.integer :applications_count, default: 0
      t.string :location
      t.boolean :is_remote, default: false

      t.timestamps
    end
    add_index :jobs, :status
    add_index :jobs, :employment_type
    add_index :jobs, :published_at
    add_index :jobs, :expires_at
  end
end
