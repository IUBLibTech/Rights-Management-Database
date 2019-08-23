class AddPublisherToWork < ActiveRecord::Migration
  def change
    add_column :works, :publisher, :string
  end
end
