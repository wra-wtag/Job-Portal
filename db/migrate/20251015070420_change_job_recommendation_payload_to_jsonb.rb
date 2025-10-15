class ChangeJobRecommendationPayloadToJsonb < ActiveRecord::Migration[8.0]
  def up
    change_column :job_recommendations, :payload, :jsonb, default: {}, using: 'payload::jsonb'
    add_index :job_recommendations, :payload, using: :gin
  end

  def down
    remove_index :job_recommendations, :payload
    change_column :job_recommendations, :payload, :json, default: {}, using: 'payload::json'
  end
end
