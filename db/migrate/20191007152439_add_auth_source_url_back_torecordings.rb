class AddAuthSourceUrlBackTorecordings < ActiveRecord::Migration
  def change
    add_column :recordings, :authority_source_url, :text
  end
end
