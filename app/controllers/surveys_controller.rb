class SurveysController < ApplicationController
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource

  def edit
  end

  def update
  end

  def new
  end

  def update
  end

  def show
    @survey_submission = @survey.survey_submissions.new
  end

  def reply
    survey_submission = params[:survey_submission]

    @survey.survey_questions.each do |survey_question|
      reply = survey_question.survey_replies.find_by(user: current_user)
      if reply
        reply.update_attributes(text: survey_submission["#{survey_question.id}"].join(','))
      else
        survey_question.survey_replies.create!(text: survey_submission["#{survey_question.id}"].join(','), user: current_user)
      end
    end

    redirect_to :back
  end

end
