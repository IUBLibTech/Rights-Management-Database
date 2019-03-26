class CreatePodObjects < ActiveRecord::Migration
  def change
    create_table :pod_objects do |t|

      t.timestamps null: false
    end
  end
end
