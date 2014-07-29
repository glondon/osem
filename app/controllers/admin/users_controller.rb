module Admin
  class UsersController < ApplicationController
    before_filter :verify_admin

    def index
      @users = User.all
    end

    def show
      @user = User.find(params[:id])

      # Variable @show_attributes holds the attributes that are visible for the 'show' action
      # If you want to change the attributes that are shown in the 'show' action of users
      # add/remove the attributes in the following string array
      @show_attributes = %w(name email affiliation biography registered attended created_at
                            updated_at sign_in_count current_sign_in_at last_sign_in_at
                            current_sign_in_ip last_sign_in_ip)
    end

    def update
      user = User.find(params[:id])
      user.update_attributes!(params[:user])
      redirect_to admin_users_path, notice: "Updated #{user.email}"
    end

    def edit
      @user = User.find(params[:id])
    end

    def delete
      @user = User.find(params[:id])
    end

    def destroy
      @user = User.find(params[:id])

      remove_user = true

      # Delete events that are not schedule.
      @user.events.each do |event|
        if event.start_time.present?
          remove_user = false
        else
          event.destroy
        end
      end

      if @user.votes.present?
        remove_user = false
      end

      if remove_user
        if @user.destroy
          flash[:success] = "Account for #{@user.name} deleted."
          redirect_to admin_users_path
        else
          flash[:alert] = "Account for #{@user.name} could not be deleted."
          redirect_to admin_users_path
        end
      else
        remove_user_info
        if @user.save!
          redirect_to admin_users_path(success: "Account for #{@user.name} deleted. The user had scheduled events.")
        else
          redirect_to admin_users_path(alert: "Account for #{@user.name} could not be deleted.1")
        end
      end
    end

    private
    def remove_user_info
      user_deleted = User.new(name: 'User deleted', email: "deleted@localhost.#{@user.id}",
                              biography: 'Data is no longer available for deleted user.',
                              password: Devise.friendly_token[0, 20])
      user_deleted.skip_confirmation!

      @user.attribute_names.each do |attr|
        unless attr == 'id' || attr == 'created_at'
          @user.update_column(:"#{attr}", user_deleted.send(attr))
        end
      end
    end
  end
end
