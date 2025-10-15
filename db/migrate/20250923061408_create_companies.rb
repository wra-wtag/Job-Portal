class CreateCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name
      t.string :slug
      t.text :description
      t.string :location
      t.string :website
      t.string :industry
      t.string :size
      t.string :logo
      t.string :status, null: false, default: 'pending'
      t.datetime :approved_at
      t.references :approved_by, null: true, foreign_key: { to_table: :users }

      t.timestamps
    end

    add_index :companies, :slug, unique: true
    add_index :companies, :status
    add_index :companies, :industry
  end
end
