# frozen_string_literal: true

FactoryBot.define do
  factory :work_record do
    association :department
    association :staff_user, factory: :user
    association :customer
    content { 'テスト作業内容' }
    work_date { Date.current }
    work_type { :support }
    status { :in_progress }
  end
end
