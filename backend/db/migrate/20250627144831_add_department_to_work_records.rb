# frozen_string_literal: true

class AddDepartmentToWorkRecords < ActiveRecord::Migration[7.2]
  def change
    add_reference :work_records, :department, foreign_key: true
  end
end
