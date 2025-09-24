FactoryBot.define do
  factory :user_skill do
    association :user
    association :skill
    experience_years { rand(0..10) }
  end
end
