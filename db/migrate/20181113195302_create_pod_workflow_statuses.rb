class CreatePodWorkflowStatuses < ActiveRecord::Migration
  def change
    create_table :pod_workflow_statuses do |t|

      t.timestamps null: false
    end
  end
end
