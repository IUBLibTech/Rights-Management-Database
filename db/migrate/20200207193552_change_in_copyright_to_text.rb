class ChangeInCopyrightToText < ActiveRecord::Migration
  def change
    change_column :recordings, :in_copyright, :string, default: ''
  end
end
