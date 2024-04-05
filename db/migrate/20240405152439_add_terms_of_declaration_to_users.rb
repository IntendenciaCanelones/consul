class AddTermsOfDeclarationToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :terms_of_declaration, :boolean, default: false
  end
end
