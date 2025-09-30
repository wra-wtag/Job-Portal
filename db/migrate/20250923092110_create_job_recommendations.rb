class CreateJobRecommendations < ActiveRecord::Migration[8.0]
  def change
    create_table :job_recommendations do |t|
      t.references :user, null: false, foreign_key: true
      t.json :payload, null: false
      t.string :algorithm_version, null: false
      t.datetime :generated_at, null: false
      t.datetime :scheduled_for
      t.datetime :sent_at

      t.timestamps
    end

    add_index :job_recommendations, :scheduled_for
  end
end
