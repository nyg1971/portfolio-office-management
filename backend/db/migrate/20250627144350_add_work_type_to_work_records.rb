# frozen_string_literal: true

class AddWorkTypeToWorkRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :work_records, :work_type, :integer
  end
end
