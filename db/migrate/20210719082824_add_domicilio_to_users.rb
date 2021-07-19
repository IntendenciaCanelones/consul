class AddDomicilioToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :domicilio, :string
  end
end
