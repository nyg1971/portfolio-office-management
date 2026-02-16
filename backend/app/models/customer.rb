# frozen_string_literal: true

class Customer < ApplicationRecord
  include Validatable

  belongs_to :department
  has_many :work_records, dependent: :destroy
  has_many :assigned_users, through: :work_records, source: :staff_user

  validates_required :name
  validates_length_with_message :name, max: 100

  validates_required :status
  validates_enum_inclusion :status

  validates_required :customer_type
  validates_enum_inclusion :customer_type

  enum :status, {
    active: 0,
    inactive: 1,
    pending: 2
  }, prefix: :status

  enum :customer_type, {
    regular: 0,
    premium: 1,
    corporate: 2
  }, prefix: :type
end
