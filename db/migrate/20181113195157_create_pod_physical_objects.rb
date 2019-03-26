class CreatePodPhysicalObjects < ActiveRecord::Migration
  def change
    create_table :pod_physical_objects do |t|

      t.timestamps null: false
    end
  end
end
