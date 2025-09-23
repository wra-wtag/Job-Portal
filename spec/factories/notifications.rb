FactoryBot.define do
  factory :notification do
    user { nil }
    kind { "MyString" }
    title { "MyString" }
    content { "MyText" }
    read_at { "2025-09-22 18:46:06" }
  end
end
