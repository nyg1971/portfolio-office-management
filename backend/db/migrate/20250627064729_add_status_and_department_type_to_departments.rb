# frozen_string_literal: true

class AddStatusAndDepartmentTypeToDepartments < ActiveRecord::Migration[7.2]
  def change
    change_table :departments, bulk: true do |t|
      t.integer :status
      t.integer :department_type
    end
  end
end
