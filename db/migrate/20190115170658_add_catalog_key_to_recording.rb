class AddCatalogKeyToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :catalog_key, :text
  end
end
