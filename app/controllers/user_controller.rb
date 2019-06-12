class UserController < ApplicationController

  def ldap_lookup
    @user = User.ldap_lookup
  end

  def index
    @users = User.all
  end

  def ajax_set_user_unit
    @user = User.where(username: params[:username]).first
    if User::WEB_ADMINS.include? User.current_username
      begin
        @user[params[:unit].to_sym] = true?(params[:access])
        @user.save!
        render json: {msg: "#{@user.username} access to #{params[:unit]} updated!", access: true?(params[:access])}
      rescue => error
        puts error.backtrace
        render json: {errors: @user.errors.full_messages}, status: 500
      end
    else
      render json: {errors: "You are not authorized to change access."}, status: 403
    end
  end

  def ajax_set_user_ignore_ads

  end

end
