# handles basic authentication for the services controller
module BasicAuthenticationHelper

  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.application.secrets[:service_username] && password == Rails.application.secrets[:service_password]
    end
  end
end