FactoryBot.define do
  factory :user_skill do
    association :user
    association :skill
    years_of_experience { rand(0..10) }
  end
end
