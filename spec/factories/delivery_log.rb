FactoryBot.define do
  factory :delivery_log do
    announcement
    guardian
    read { false }
    
    trait :read do
      read { true }
      read_at { Time.current }
    end
  end
end
