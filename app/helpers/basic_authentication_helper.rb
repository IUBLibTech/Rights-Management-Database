module BasicAuthenticationHelper

  protected
  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      username == Rails.configuration.rmd[:service_username] && password == Rails.configuration.rmd[:service_password]
    end
  end
end