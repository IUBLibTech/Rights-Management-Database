require 'net/ssh'

module TunneledConnection

  def self.connect
    Net::SSH::Gateway.new("#{Rails.application.secrets[:tunnel_host]}", Rails.application.secrets[:tunnel_username], keys: ['certificate.pem']).open("#{Rails.application.secrets[:remote_hostname]}", 3306, 3307)
  end

end