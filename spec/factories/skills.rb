FactoryBot.define do
  factory :skill do
    name { Faker::ProgrammingLanguage.name }
    category { [ 'Programming', 'Framework', 'Database', 'Tool', 'Soft Skill' ].sample }
  end
end
