class CreateApplications < ActiveRecord::Migration[8.0]
  def change
    create_table :applications do |t|
      t.references :job, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.text :cover_letter
      t.string :status, null: false, default: 'applied'
      t.datetime :applied_at, null: false

      t.timestamps
    end

    add_index :applications, [ :job_id, :user_id ], unique: true
    add_index :applications, :status
    add_index :applications, :applied_at
  end
end
