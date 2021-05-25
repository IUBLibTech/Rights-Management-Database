# Does not inherit from ApplicationController to avoid requiring sign-in here
class SessionsController < ActionController::Base
  include SessionsHelper
  require 'net/http'

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # def cas_reg
  #   "https://cas-reg.uits.iu.edu"
  # end

  # def cas
  #   "https://cas.iu.edu"
  # end

  def logger
    @@logger ||= Logger.new("#{Rails.root}/log/iu_login.log")
  end

  def iu_login_staging
    "https://idp-stg.login.iu.edu/idp/profile"
  end

  def new
    new_iu_login
  end

  def new_iu_login
    url = "#{iu_login_staging}/cas/login?service=#{root_url}sessions/validate_login"
    logger.warn "Redirecting to IU Login for authentication: #{url}"
    redirect_to(url)
  end

  def validate_login
    @casticket=params[:ticket]
    logger.warn "Returning from IU Login, cas ticket: #{params}"
    url = "#{iu_login_staging}/cas/serviceValidate?ticket=#{@casticket}&service=#{root_url}"
    uri = URI.parse(url)
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request.ssl_version = :TLSv1_2
    response = request.get("#{iu_login_staging}/cas/serviceValidate?ticket=#{@casticket}&service=#{root_url}sessions/validate_login")
    @resp = response.body
    user = extract_username(@resp)
    if User.authenticate(user)
      sign_in(user)
      redirect_back_or_to root_url
    else
      redirect_to "#{root_url}denied.html"
    end
  end

  def destroy
    sign_out
    redirect_to 'https://idp-stg.login.iu.edu/idp/profile/cas/logout'
  end

  private
  def extract_username(response)
    doc = Nokogiri::XML(response)
    node = doc.xpath("//cas:user").first
    if node
      node.content
    else
      nil
    end
  end

end
