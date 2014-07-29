class RegistrationsController < Devise::RegistrationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  def edit
    @openids = Openid.where(user_id: current_user.id).order(:provider)
  end

  def update
    @openids = Openid.where(user_id: current_user.id).order(:provider)
    @user = User.find(current_user.id)
    email_changed = false

    if !params[:user][:email].nil?
      if @user.email != params[:user][:email]
        email_changed = true
      else
        params[:user].delete :email
      end
    end

    password_changed = false
    if !params[:user][:password].nil?
      if !params[:user][:password].empty?
        password_changed = true
      else
        params[:user].delete :password
        params[:user].delete :password_confirmation
      end
    end

    if email_changed || password_changed
      successfully_updated = @user.update_with_password(account_update_params)
    else
      params[:user].delete :current_password
      successfully_updated = @user.update_without_password(account_update_params)
    end

    if successfully_updated
      if email_changed
        unless @user.nil?
          @user.update_attribute('email', params[:user][:email])
        end
        set_flash_message :notice, :update_needs_confirmation
      else
        set_flash_message :notice, :updated
      end
      # Sign in the user bypassing validation in case his password changed
      sign_in @user, bypass: true
      redirect_to after_update_path_for(@user)
    else
      flash[:alert] = 'Updating account failed. ' \
        "#{@user.errors.full_messages.join('. ')}."
      render 'edit'
    end
  end

  def destroy
    @user = current_user
    remove_user = true

    # Delete events that are not schedule.
    # No reason to keep records of unconfirmed events that will never be confirmed because they lack a submitter/speaker
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
        sign_out @user
        redirect_to root_path(success: "Account for #{user.name} deleted.")
      else
        redirect_to edit_user_registration_path(@user, alert: 'Account could not be deleted!')
      end
    else
      remove_user_info
      if @user.save!
        sign_out @user
        redirect_to root_path(success: "Account for #{user.name} deleted.")
      else
        redirect_to edit_user_registration_path(@user, alert: 'Account could not be deleted!')
      end
    end
  end

  protected
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

  def after_update_path_for(resource)
    edit_user_registration_path(resource)
  end

  def after_sign_up_path_for(resource)
    edit_user_registration_path(resource)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.for(:account_update) do |u|
      u.
          permit(:email, :password, :password_confirmation, :current_password, :name, :biography,
                 :nickname, :affiliation)
    end
    devise_parameter_sanitizer.for(:sign_up) do |u|
      u.
          permit(:email, :password, :password_confirmation, :name)
    end
  end
end
