class AddEntityMetadataToPeople < ActiveRecord::Migration
  def change
    add_column :people, :entity, :boolean
    add_column :people, :company_name, :text
    add_column :people, :entity_nationality, :text
  end
end
