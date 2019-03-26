class CreateIuAffiliations < ActiveRecord::Migration
  def change
    create_table :iu_affiliations do |t|
      t.text :description
      t.timestamps null: false
    end
  end
end
