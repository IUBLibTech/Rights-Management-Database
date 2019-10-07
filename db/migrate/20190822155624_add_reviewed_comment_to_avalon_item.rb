class AddReviewedCommentToAvalonItem < ActiveRecord::Migration
  def change
    add_column :avalon_items, :reviewed_comment, :text
  end
end
