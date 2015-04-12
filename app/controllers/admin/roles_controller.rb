module Admin
  class RolesController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
#     load_and_authorize_resource find_by: :name#, except: [:show, :add_user, :remove_user]
    load_resource :user, only: [ :remove_user, :update ]
    before_action :set_selection
    # Show flash message with ajax calls
    after_filter :prepare_unobtrusive_flash, only: [:add_user, :remove_user]

    def index
      @roles = Role.where(resource: @conference)
#       @actionables = Role::ACTIONABLES
#       @default_labels = Role::LABELS.map { |x| x['name'] }

#       # Include roles from DB, except 'ACTIONABLES' and 'LABELS'
#       @custom_labels = Role.where(resource: @conference).map{ |x| x.name.titleize } -
#         Role::ACTIONABLES.map { |x| x['name']} -
#         Role::LABELS.map { |x| x['name']} -
#         ['Cfp'] # We need to individually extract due to abnormal case letters
#
#       @labels = @default_labels + @custom_labels

      @tags = Tag.where(resource: @conference)
    end

    def new
      @role = Role.new(resource: @conference)
    end

    def create
      @role = Role.new(role_params)
      @role.resource = @conference
      @role.name = format_role(@role.name)

      if @role.save
        flash[:success] = 'New role created: ' + @role.name
        redirect_to admin_conference_roles_path(@conference.short_title)
      else
        flash[:error] = 'Could not create role.' + @role.errors.full_messages.to_sentence
        render :new
      end
    end

    def show
      @users = @role.users
    end

    def edit
      @users = @role.users
    end

    def update
      role_name = @role.name

      if @role.name == 'organizer' && params[:role][:user_ids].reject(&:empty?).blank?
        flash[:error] = 'Could not remove user. The conference must have at least one organizer!'
        redirect_to admin_conference_roles_path(@conference.short_title) and return
      end

      if params[:role] && @role.update_attributes(role_params)
        flash[:success] = 'Successfully updated role ' + @role.name
        redirect_to admin_conference_roles_path(@conference.short_title)
      else
        flash[:error] = 'Could not update role! ' + @role.errors.full_messages.to_sentence
        @role.name = role_name
        render :edit
      end
    end

    def find_user
      user_name = params[:user][:name]

      @users = User.where('name LIKE ?', "%#{user_name}%")

      render 'show', formats: [:js]
    end

    def add_user
#       # Get user
#       user_id = params[:role][:user][:id]
#       @user = User.find(user_id)
#
#       if can? :add_user, Role.new(name: @selection, resource: @conference)
#         if @user.roles.include? @role
#           flash[:warning] = 'User ' + @user.email + ' already has role ' + @selection.titleize
#         else
#           @user.add_role @selection.to_sym, @conference
#           flash[:success] = 'Successfully added role ' + @selection.titleize + ' to ' + @user.email
#         end
#
#         set_selection # Reload role, to show the newly added userss
#       else
#         flash[:error] = 'Could not add user. Check your privileges!'
#       end
#
#       render 'show', formats: [:js]
    end

    def remove_user

      if can? :remove_user, @role
        if @role.name == 'organizer' && @role.users.count == 1
          flash[:error] = 'Could not remove user. The conference must have at least one organizer!'
        else
          @user.remove_role @role.name.to_sym, @conference
          flash[:success] = 'Successfully revoked role ' + @role.name.titleize + ' from ' + @user.email
        end
      else
        flash[:error] = 'Could not remove user. Check your privileges!'
      end

      render 'show', formats: [:js]
    end

    protected

    def set_selection
      # Set 'organizer' as default role, when there is no other selection
      params[:id] ? (@selection = params[:id].parameterize.underscore) : (@selection = 'organizer')

      @role = Role.find_by(name: @selection, resource: @conference)
    end

    def role_params
      params.require(:role).permit(:name, :description, user_ids: [])
    end
  end
end
