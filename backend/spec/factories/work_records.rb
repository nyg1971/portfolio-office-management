# frozen_string_literal: true

FactoryBot.define do
  factory :work_record do
    customer { nil }
    staff_user { nil }
    content { 'MyText' }
    work_date { '2025-06-20 09:52:40' }
  end
end
