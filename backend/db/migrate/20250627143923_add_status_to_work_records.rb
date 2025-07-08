# frozen_string_literal: true

class AddStatusToWorkRecords < ActiveRecord::Migration[7.2]
  def change
    add_column :work_records, :status, :integer
  end
end
