class ChangePerformaceDateBackToFullDate < ActiveRecord::Migration
  def up
    add_column :performances, :performance_date_string, :string
    change_column :performances, :performance_date, :date
  end

  def down
    remove_column :performances, :performance_date_string
    change_column :performances, :performance_date, :integer
  end
end
