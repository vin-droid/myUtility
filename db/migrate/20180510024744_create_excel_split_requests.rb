class CreateExcelSplitRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :excel_split_requests do |t|
      t.string :user_email, default: "", null: false
      t.float :file_size, default: 0.0, null: false
      t.integer :status, default: 0, null: false
      t.string :errors, array: true, default: []

      t.timestamps
    end
  end
end
