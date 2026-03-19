class CreateStudents < ActiveRecord::Migration[7.2]
  def change
    create_table :students, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name

      t.timestamps
    end
  end
end
