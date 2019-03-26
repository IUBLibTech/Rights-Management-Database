class AddAuthorityToPeople < ActiveRecord::Migration
  def change
    add_column :people, :authority_source_url, :text
  end
end
