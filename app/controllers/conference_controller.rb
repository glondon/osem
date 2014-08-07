class ConferenceController < ApplicationController
  load_and_authorize_resource find_by: :short_title

  def show
  end

  def gallery_photos
    @photos = @conference.photos
    render "photos", formats: [:js]
  end
end
