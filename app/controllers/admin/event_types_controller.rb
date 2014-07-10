module Admin
  class EventTypesController < Admin::BaseController
    authorize_resource
    load_and_authorize_resource :conference, find_by: :short_title

    def show
      render :eventtypes
    end

    def update
      @conference.update_attributes!(params[:conference])
      redirect_to(admin_conference_event_types_path(
                  conference_id: @conference.short_title),
                  notice: 'Event types were successfully updated.')
    rescue Exception => e
      redirect_to(admin_conference_event_types_path(
                  conference_id: @conference.short_title),
                  alert: "Event types update failed: #{e.message}")
    end
  end
end
