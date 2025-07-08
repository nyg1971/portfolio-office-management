# frozen_string_literal: true

class CreateCustomers < ActiveRecord::Migration[7.2]
  def change
    create_table :customers do |t|
      t.string :name
      t.integer :customer_type
      t.belongs_to :department, null: false, foreign_key: true

      t.timestamps
    end
  end
end
