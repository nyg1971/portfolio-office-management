# frozen_string_literal: true

class User < ApplicationRecord
  include Validatable

  has_many :work_records, foreign_key: 'staff_user_id', dependent: :destroy, inverse_of: :staff_user
  has_many :assigned_customers, through: :work_records, source: :customer

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  validates_required :role

  enum :role, {
    staff: 0,
    manager: 1,
    admin: 2
  }

  after_initialize :set_default_role, if: :new_record?

  def as_json_for_api
    as_json(only: %i[id email role created_at updated_at])
  end

  private

  def set_default_role
    self.role ||= :staff
  end
end
