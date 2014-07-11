module Admin
  class VenueController < ApplicationController
    load_and_authorize_resource :conference, find_by: :short_title
    load_and_authorize_resource :venue, through: :conference, singleton: true

    def index
    end

    def update
      @venue = @conference.venue
      if @venue.update_attributes!(params[:venue])
        redirect_to(admin_conference_venue_info_path(conference_id: @conference.short_title),
                    notice: 'Venue was successfully updated.')
      else
        redirect_to(admin_conference_venue_info_path(conference_id: @conference.short_title),
                    notice: 'Venue Updation Failed!')
      end
    end

    def show
      @venue = @conference.venue
      render :venue_info
    end

  end
end
