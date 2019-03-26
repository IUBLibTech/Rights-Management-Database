class CreatePodPulls < ActiveRecord::Migration
  def change
    create_table :pod_pulls do |t|
      t.datetime :pull_timestamp, null: false
      t.timestamps null: false
    end
  end
end
