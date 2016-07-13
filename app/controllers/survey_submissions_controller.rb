class SurveySubmissionsController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_resource :survey
  load_and_authorize_resource

  def edit
  end

  def update
  end

  def new
  end

  def show
  end
end
