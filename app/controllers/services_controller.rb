class ServicesController < ApplicationController
  include BasicAuthenticationHelper
  # Since this is an API, use :null_session instead of the rails default token.
  protect_from_forgery with: :null_session

  before_action :authenticate

  # json response given a barcode what the access decision is for the recording
  # get /services/access_decision_by_barcode/:mdpi_barcode
  def access_decision_by_barcode
    bc = params[:mdpi_barcode]
    r = Recording.where(mdpi_barcode: bc).first
    response = r.nil? ? no_recording_msg(bc) : access_decision_msg(r)
    render json: response
  end

  # json response containing access decisions for ALL records in RMD
  # get '/services/access_decisions_by_barcodes'
  def access_decisions_by_barcodes
    render json: Recording.all.pluck(:mdpi_barcode, :access_determination).as_json
  end

  # json response containing a fedora id (a work, not a recording) mapped to the aggregate decision
  # of the works constituent recordings
  #
  def access_decision_by_fedora_id
    r = Recording.where(fedora_item_id: params[:fid])
    if r.size == 0
      render json: {status: "error", fedora_id: params[:fid], msg: "Could not find a Recording(s) with Fedora ID: #{params[:fid]}"}
    else
      render json: {status: "success", fedora_id: params[:fid], msg: "Need to calculate most restrictive access for items with Fedora ID: #{params[:fid]}"}
    end
  end

  def access_decisions_by_fedora_ids

  end

  private
  def no_recording_msg(bc)
    {status: "error", mdpi_barcode: bc, msg: "Could not find a Recording with MDPI barcode #{bc}"}
  end

  def access_decision_msg(r)
    {status: "success", mdpi_barcode: r.mdpi_barcode, access_decision: r.access_determination}
  end

end
