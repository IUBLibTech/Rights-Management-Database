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

  def iu_login_staging
    "https://idp-stg.login.iu.edu/idp/profile"
  end

  def new
    #redirect_to("#{cas}/cas/login?cassvc=ANY&casurl=#{root_url}sessions/validate_login")
    new_iu_login
  end

  def new_iu_login
    redirect_to("#{iu_login_staging}/cas/login?service=#{root_url}sessions/validate_login")
  end

  def validate_login
    @casticket=params[:casticket]
    #uri = URI.parse("#{cas}/cas/validate?cassvc=ANY&casticket=#{@casticket}&casurl=#{root_url}")
    uri = URI.parse("#{iu_login_staging}/cas/serviceValidate?ticket=#{@casticket}&service=#{root_url}")
    request = Net::HTTP.new(uri.host, uri.port)
    request.use_ssl = true
    request.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request.ssl_version = :TLSv1_2
    response = request.get("#{iu_login_stagin}/cas/validate?ticket=#{@casticket}&service=#{root_url}")
    @resp = response.body.strip
    if User.authenticate(@resp)
      sign_in(@resp)
      redirect_back_or_to root_url
    else
      redirect_to "#{root_url}denied.html"
    end
  end

  def destroy
    sign_out
    redirect_to 'https://cas.iu.edu/cas/logout'
  end

end
