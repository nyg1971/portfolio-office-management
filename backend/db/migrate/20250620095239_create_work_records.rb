# frozen_string_literal: true

class CreateWorkRecords < ActiveRecord::Migration[7.2]
  def change
    create_table :work_records do |t|
      t.belongs_to :customer, null: false, foreign_key: true
      t.references :staff_user, null: false, foreign_key: { to_table: :users }
      t.text :content
      t.datetime :work_date

      t.timestamps
    end
  end
end
