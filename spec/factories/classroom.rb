FactoryBot.define do
  factory :classroom do
    school
    name { "Class #{Faker::Alphanumeric.alpha(number: 2).upcase}" }
    grade { "#{Faker::Number.between(from: 1, to: 12)}th Grade" }
  end
end
