# frozen_string_literal: true

FactoryBot.define do
  factory :customer do
    name { '田中商事株式会社' }
    customer_type { :regular }
    status { :active }
    association :department

    trait :premium do
      name { 'プレミアム顧客' }
      customer_type { :premium }
    end

    trait :corporate do
      name { '大手企業株式会社' }
      customer_type { :corporate }
    end

    trait :inactive do
      status { :inactive }
    end
  end
end
