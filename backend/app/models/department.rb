# frozen_string_literal: true

class Department < ApplicationRecord
  include Validatable

  has_many :users, dependent: :restrict_with_error
  has_many :customers, dependent: :restrict_with_error
  has_many :work_records, through: :customers
  has_many :assigned_staff, through: :work_records, source: :staff_user

  validates_required :name
  validates_length_with_message :name, max: 100
  validates_unique :name
  validates_japanese_name :name

  validates_length_with_message :address, max: 500
  validates_japanese_name :address, allow_blank: true

  enum :status, {
    active: 0,
    inactive: 1,
    archived: 2
  }, prefix: :status

  enum :department_type, {
    sales: 0,
    engineering: 1,
    administration: 2,
    support: 3,
    other: 4
  }, prefix: :type
end
