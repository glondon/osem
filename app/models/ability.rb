class Ability
  include CanCan::Ability

  def initialize(user)
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Order Abilities
    # (Check https://github.com/CanCanCommunity/cancancan/wiki/Ability-Precedence)
    # Check roles of user, using rolify. Role name is *case sensitive*
    # user.is_organizer? or user.has_role? :organizer
    # user.is_cfp_of? Conference or user.has_role? :cfp, Conference
    # user.is_info_desk_of? Conference
    # user.is_volunteer_coordinator_of? Conference
    # user.is_attendee_of? Conference
    # The following is wrong because a user will only have 'cfp' role for a specific conference
    # user.is_cfp? # This is always false


    user ||= User.new # guest user (not logged in)

    if user.new_record?
      guest(user)
    else
      # Ids of all the conferences for which the user has an 'organizer' role
      conf_ids_for_organizer =
          Conference.with_role(:organizer, user).pluck(:id)
      venue_ids_for_organizer =
          Conference.with_role(:organizer, user).pluck(:venue_id)
      conf_ids_for_cfp =
        Conference.with_role(:cfp, user).pluck(:id)
      venue_ids_for_cfp =
          Conference.with_role(:cfp, user).pluck(:venue_id)
      # Ids of all the conferences for which the user has an 'info_desk' role
      conf_ids_for_info_desk =
          Conference.with_role(:info_desk, user).pluck(:id)
      # Ids of all the conferences for which the user has a 'volunteer_coordinator' role
      conf_ids_for_volunteer_coordinator =
          Conference.with_role(:volunteer_coordinator, user).pluck(:id)

      conference_ids = conf_ids_for_organizer + conf_ids_for_cfp + conf_ids_for_info_desk + conf_ids_for_volunteer_coordinator

      roles = Role::ACTIONABLES.map {|i| i.parameterize.underscore}
      if (user.roles.pluck(:name) & roles).empty? && !user.is_admin# User has no roles
        signed_in(user)
      else
        # User with role
        can :manage, User if user.is_admin
        can [:new, :create], Conference if user.is_admin
        # can :manage, Role, resource_id:
        can [:index, :show], Conference
        can :manage, Conference, id: conf_ids_for_organizer
        can :manage, Venue, id: venue_ids_for_organizer
        can :index, Venue, id: venue_ids_for_cfp
        can :manage, Registration, conference_id: conf_ids_for_organizer + conf_ids_for_info_desk
        can :manage, Question, conference_id: conf_ids_for_organizer + conf_ids_for_info_desk
        can :manage, Vposition, conference_id: conf_ids_for_organizer + conf_ids_for_volunteer_coordinator
        can :manage, Vday, conference_id: conf_ids_for_organizer + conf_ids_for_volunteer_coordinator
        # The ability to manage an Event means that:
        # the user can also edit the schedule and that
        # the user can also vote
        can :manage, Event, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, CallForPapers, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, EventType, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, Track, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, DifficultyLevel, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, EmailSettings, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, Campaign, conference_id: conf_ids_for_organizer
        can :manage, Lodging, venue_id: venue_ids_for_organizer
        can :manage, Photo, conference_id: conf_ids_for_organizer
        can :manage, Room, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
        can :manage, Sponsor, conference_id: conf_ids_for_organizer
        can :manage, SponsorshipLevel, conference_id: conf_ids_for_organizer
        can :manage, SupporterLevel, conference_id: conf_ids_for_organizer
        # SupporterRegistration
        can :manage, Target, conference_id: conf_ids_for_organizer
        can :manage, Commercial
        can :manage, Contact, conference_id: conf_ids_for_organizer
      end
    end
  end

  def guest(user)
    ## Abilities for everyone, even guests (not logged in users)
    can :show, Conference do |conference|
      conference.make_conference_public == true
    end

    can :show, Event do |event|
      event.state == 'confirmed'
    end

    can :index, :schedule # show?
  end

  def signed_in(user)
    guest(user) # Inherits abilities of guest
    # Conference Registration
    can :manage, Registration, user_id: user.id

    ## Proposals
    # Users can edit their own proposals
    # Can manage an event if the user is a speaker or a submitter of that event

    can :manage, Event do |event|
      event.event_users.where(:user_id => user.id).present?
    end

    can :manage, EventAttachment do |ea|
      Event.find(ea.event_id).event_users.where(user_id: user.id).present?
    end
    can :create, EventAttachment
  end
end
