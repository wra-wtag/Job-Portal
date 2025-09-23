FactoryBot.define do
  factory :notification do
    user { nil }
    kind { "MyString" }
    title { "MyString" }
    content { "MyText" }
    read_at { "2025-09-23 14:38:56" }
  end
end
