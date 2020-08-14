class AddNameToUpload < ActiveRecord::Migration[6.0]
  def change
    add_column :uploads, :name, :string
  end
end
