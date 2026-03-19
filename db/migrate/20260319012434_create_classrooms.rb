class CreateClassrooms < ActiveRecord::Migration[7.2]
  def change
    create_table :classrooms do |t|
      t.references :school, null: false, foreign_key: true
      t.string :name
      t.string :grade

      t.timestamps
    end
  end
end
