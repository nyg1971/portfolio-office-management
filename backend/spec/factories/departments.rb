# frozen_string_literal: true

FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "部署#{n}" }
    address { '住所テキスト' }
    status { :active }
    department_type { :other }

    trait(:status_inactive) do
      status { :inactive }
    end
  end
end
