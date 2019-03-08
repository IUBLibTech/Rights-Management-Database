class ServicesController < ApplicationController
  include BasicAuthenticationHelper
  # Since this is an API, use :null_session instead of the rails default token.
  protect_from_forgery with: :null_session

  before_action :authenticate

  def access_decision
    bc = params[:mdpi_barcode]
    r = Recording.where(mdpi_barcode: bc).first
    response = r.nil? ? no_recording_msg(bc) : access_decision_msg(r)
    render json: response
  end

  private
  def no_recording_msg(bc)
    {status: "error", mdpi_barcode: bc, msg: "Could not find a Recording with MDPI barcode #{bc}"}
  end

  def access_decision_msg(r)
    {status: "success", mdpi_barcode: r.mdpi_barcode, access_decision: r.access_determination}
  end

end
