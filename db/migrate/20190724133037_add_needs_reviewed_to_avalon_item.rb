class AddNeedsReviewedToAvalonItem < ActiveRecord::Migration
  def change
    add_column :avalon_items, :needs_review, :boolean
    add_column :avalon_items, :needs_review_comment, :text
    add_column :avalon_items, :reviewed, :boolean
    add_column :avalon_items, :review_requester, :string
  end
end
