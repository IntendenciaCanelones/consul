class AddFkToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :geozones_area, foreign_key: true
  end
end
