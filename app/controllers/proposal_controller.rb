class ProposalController < ApplicationController
  before_filter :verify_user, except: [:show]
  load_resource :conference, find_by: :short_title
  load_and_authorize_resource :event, parent: false
  before_filter :setup

  def setup
    @user = current_user if current_user
    @url = conference_proposal_index_path(@conference.short_title)
    @event_types = @conference.event_types
  end

  def index
    @events = current_user.proposals(@conference)
  end

  def destroy
    if @event
      @event.withdraw
      @event.save
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Proposal withdrawn.')
    else
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  alert: 'Error! Could not find proposal!')
    end
  end

  def new
    authorize! :new, Event
    @url = conference_proposal_index_path(@conference.short_title)
    @event = Event.new
  end

  def edit
    authorize! :edit, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])
    @attachments = @event.event_attachments
  end

  def create
    authorize! :create, Event
    @url = conference_proposal_index_path(@conference.short_title)

    params[:event].delete :user
    @event = Event.new(params[:event])
    @event.conference = @conference

    # First, update the submitter's info, if they've changed anything
    current_user.assign_attributes(params[:user])
    if current_user.changed?
      current_user.save
    end

    @event.event_users.new(user: current_user,
                           event_role: 'submitter')
    @event.event_users.new(user: current_user,
                           event_role: 'speaker')

    if !@event.save
      flash[:error] = "Could not submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    registration = current_user.registrations.where(conference_id: @conference.id).first
    ahoy.track 'Event submission', title: 'New submission'
    if registration.nil?
      redirect_to(register_conference_path(@conference.short_title),
                  alert: 'Event was successfully submitted.
                 You should register for the conference now.')
    else
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Event was successfully submitted.')
    end
  end

  def update
    authorize! :update, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    # First, update the submitter's info, if they've changed anything
    current_user.assign_attributes(params[:user])
    if current_user.changed?
      current_user.save
    end

    # FIXME: Hmmmmm
    params[:event].delete :users_attributes
    params[:event].delete :user

    if !@event.update(params[:event])
      flash[:error] = "Could not update proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                notice: "Proposal was successfully updated.")
  end

  def destroy
    authorize! :destroy, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    begin
      @event.withdraw
    rescue Transitions::InvalidTransition
      redirect_to(:back, error: "Event can't be withdrawn")
      return
    end

    @event.save(validate: false)
    redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                notice: "Proposal was successfully withdrawn.")
  end

  def confirm
    authorize! :update, @event
    @url = conference_proposal_path(@conference.short_title, params[:id])

    begin
      @event.confirm!
    rescue Transitions::InvalidTransition
      redirect_to(:back, error: "Event can't be confirmed")
      return
    end

    if !@event.save
      flash[:error] = "Could not confirm proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    if !@conference.user_registered?(current_user)
      redirect_to(register_conference_path(@conference.short_title),
                  alert: 'The proposal was confirmed. Please register to attend the conference.')
      return
    end
    redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                notice: 'The proposal was confirmed.')
  end

  def show
    @speaker = @event.speakers.first || @event.submitter
  end

  def confirm
    if @event.transition_possible? :confirm
      begin
        @event.confirm!
      rescue InvalidTransition => e
        redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                    alert: "Event was NOT confirmed: #{e.message}")
        return
      end

      if !@conference.user_registered?(current_user)
        redirect_to(conference_register_path(@conference.short_title),
                    notice: 'Event was confirmed. Please register to attend the conference.')
        return
      end
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  notice: 'Event was confirmed.')
    else
      redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                  error: "The proposal can't be re-submitted.")
      return
    end

    if !@event.save
      flash[:error] = "Could not re-submit proposal: #{@event.errors.full_messages.join(', ')}"
      render action: 'new'
      return
    end

    redirect_to(conference_proposal_index_path(conference_id: @conference.short_title),
                notice: "The proposal was re-submitted. The #{@conference.short_title} organizers will review it again.")
  end

  private

  def set_conference
    @conference = Conference.find_by(short_title: params[:conference_id])
  end

  def set_event
    @event = Event.find(params[:id])
  end
end
