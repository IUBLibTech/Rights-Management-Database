class AddNeedsReviewToRecording < ActiveRecord::Migration
  def change
    add_column :recordings, :needs_review, :boolean, default: false
  end
end
