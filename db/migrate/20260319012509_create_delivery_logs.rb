class CreateDeliveryLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :delivery_logs do |t|
      t.references :announcement, null: false, foreign_key: true
      t.references :guardian, null: false, foreign_key: true
      t.boolean :read
      t.datetime :read_at

      t.timestamps
    end
  end
end
