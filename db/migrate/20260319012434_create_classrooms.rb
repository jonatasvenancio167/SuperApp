class CreateClassrooms < ActiveRecord::Migration[7.2]
  def change
    create_table :classrooms, id: :uuid, default: "gen_random_uuid()" do |t|
      t.references :school, null: false, foreign_key: true, type: :uuid
      t.string :name
      t.string :grade

      t.timestamps
    end
  end
end
