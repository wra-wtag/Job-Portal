class CreateRecruiterMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :recruiter_memberships do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: true
      t.string :role, null: false, default: 'standard'
      t.string :title
      t.boolean :is_primary, default: false
      t.json :contact_info, default: {}

      t.timestamps
    end
    add_index :recruiter_memberships, [ :user_id, :company_id ], unique: true
  end
end
