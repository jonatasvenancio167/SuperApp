class CreateGuardians < ActiveRecord::Migration[7.2]
  def change
    create_table :guardians do |t|
      t.string :name
      t.string :email

      t.timestamps
    end
  end
end
