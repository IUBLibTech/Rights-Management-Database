class TestController < ApplicationController

  #FIXME: remove from produciton use

  # action that provides a webpage UI to test ServicesController#access_decision_by_barcodes
  def test_access_decisions
    @username = Rails.application.secrets.service_username
    @password = Rails.application.secrets.service_password
  end

end
