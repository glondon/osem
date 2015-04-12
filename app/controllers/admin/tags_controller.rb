module Admin
  class TagsController < Admin::BaseController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource find_by: :name

    def index
      @tags = Tag.where(resource: @conference)
    end

    def new
      @tag = Tag.new(resource: @conference)
    end

    def create
      @tag = Tag.new(tag_params)
      @tag.resource = @conference
      @tag.name = @tag.name.parameterize.underscore

      if @tag.save
        flash[:success] = 'New tag ' + @tag.name + ' was successfully created!'
        redirect_to admin_conference_tags_path(@conference.short_title)
      else
        flash[:error] = 'Could not create tag.' + @tag.errors.full_messages.to_sentence
        render :new
      end
    end

    def show
      @users = @tag.users
    end

    def edit
      @users = @tag.users
    end

    def update
      tag_name = @tag.name

      if params[:tag] && @tag.update_attributes(tag_params)
        flash[:success] = 'Successfully updated tag ' + @tag.name
        redirect_to admin_conference_tags_path(@conference.short_title)
      else
        flash[:error] = 'Could not update tag! ' + @tag.errors.full_messages.to_sentence
        @tag.name = tag_name
        render :edit
      end
    end

    def find_user
      user_name = params[:user][:name]

      @users = User.where('name LIKE ?', "%#{user_name}%")

      render 'show', formats: [:js]
    end

    protected

    def set_selection
      # Set 'organizer' as default tag, when there is no other selection
      params[:id] ? (@selection = params[:id].parameterize.underscore) : (@selection = 'organizer')

      @tag = Role.find_by(name: @selection, resource: @conference)
    end

    def tag_params
      params.require(:tag).permit(:name, :description, user_ids: [])
    end
  end
end
