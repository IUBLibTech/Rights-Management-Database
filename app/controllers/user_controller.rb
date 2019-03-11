class UserController < ApplicationController

  def ldap_lookup
    @user = User.ldap_lookup
  end

end
