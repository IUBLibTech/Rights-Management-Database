class ServiceController < ApplicationController
  include BasicAuthenticationHelper
  before_action :authenticate

  def mco_push
    render text: "TBD what comes in and what goes out"
  end
end
