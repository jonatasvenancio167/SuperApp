class CreateDeliveryLogs < ActiveRecord::Migration[7.2]
  def change
    create_table :delivery_logs, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :announcement, null: false, foreign_key: true, type: :uuid
      t.references :guardian, null: false, foreign_key: true, type: :uuid
      t.boolean :read
      t.datetime :read_at

      t.timestamps
    end
  end
end
