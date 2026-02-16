# frozen_string_literal: true

class WorkRecord < ApplicationRecord
  include Validatable

  belongs_to :customer
  belongs_to :staff_user, class_name: 'User', inverse_of: :work_records
  belongs_to :department

  validates_required :content
  validates_length_with_message :content, max: 1000

  validates_required :work_date

  enum :status, {
    in_progress: 0,
    completed: 1,
    on_hold: 2,
    cancelled: 3
  }, prefix: :status

  enum :work_type, {
    consultation: 0,
    support: 1,
    maintenance: 2,
    emergency: 3
  }, prefix: :type

  before_create :set_default_status

  private

  def set_default_status
    self.status ||= :in_progress
  end
end
