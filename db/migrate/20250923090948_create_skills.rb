class CreateSkills < ActiveRecord::Migration[8.0]
  def change
    create_table :skills do |t|
      t.string :name, null: false
      t.string :category

      t.timestamps
    end

    add_index :skills, :name, unique: true
    add_index :skills, :category
  end
end
