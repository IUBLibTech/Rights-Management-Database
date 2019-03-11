class User < ActiveRecord::Base
  attr_accessor :ldap_lookup_key
  include LDAPGroupsLookup::Behavior

  def self.authenticate(username)
    # FIXME: update this to check against ADS groups and unit access
    return !username.nil?
  end

  def self.current_username=(user)
    Thread.current[:current_username] = user
  end

  def self.current_username
    user_string = Thread.current[:current_username].to_s
    user_string.blank? ? "UNAVAILABLE" : user_string
  end

  def self.ldap_lookup
    u = User.new
    u.ldap_lookup_key = User.current_username
    u.ldap_groups
    u
  end

end
