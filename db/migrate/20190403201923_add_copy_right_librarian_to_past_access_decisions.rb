class AddCopyRightLibrarianToPastAccessDecisions < ActiveRecord::Migration
  def change
    add_column :past_access_decisions, :copyright_librarian, :boolean, default: false
  end
end
