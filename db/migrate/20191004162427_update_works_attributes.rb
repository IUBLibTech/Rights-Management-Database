class UpdateWorksAttributes < ActiveRecord::Migration
  def change
    remove_column :works, :publisher, :string
    add_column :works, :copyright_renewed, :boolean
  end
end
