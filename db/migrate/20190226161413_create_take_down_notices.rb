class CreateTakeDownNotices < ActiveRecord::Migration
  def change
    create_table :take_down_notices do |t|
      t.timestamps null: false
    end
  end
end
