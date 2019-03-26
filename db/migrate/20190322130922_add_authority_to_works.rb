class AddAuthorityToWorks < ActiveRecord::Migration
  def change
    add_column :works, :authority_source_url, :text
  end
end
