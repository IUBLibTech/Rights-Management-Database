class PastAccessDecision < ActiveRecord::Base
  belongs_to :avalon_item
  after_create :set_current_access

  private
  def set_current_access
    avalon_item.update_attributes!(current_access_determination_id: id)
  end
end
