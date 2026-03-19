class CreateSchools < ActiveRecord::Migration[7.2]
  def change
    create_table :schools, id: :uuid, default: "gen_random_uuid()" do |t|
      t.string :name
      t.string :code

      t.timestamps
    end
  end
end
