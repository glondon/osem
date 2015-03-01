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
      guest
    else
      roles = Role::ACTIONABLES.map { |r| r['name'].parameterize.underscore }
      if (user.roles.pluck(:name) & roles).empty? && !user.is_admin # User has no roles
        signed_in(user)
      else
        user_with_roles(user)
      end
    end
  end

  def user_with_roles(user)
    conf_ids_for_organizer = []
    conf_ids_for_cfp = []
    conf_ids_for_info_desk = []
    conf_ids_for_volunteer_coordinator = []

    # Ids of all the conferences for which the user has an 'organizer' role
    conf_ids_for_organizer =
        Conference.with_role(:organizer, user).pluck(:id) if user.has_role? :organizer, :any
    conf_ids_for_cfp =
      Conference.with_role(:cfp, user).pluck(:id) if user.has_role? :cfp, :any
    # Ids of all the conferences for which the user has an 'info_desk' role
    conf_ids_for_info_desk =
        Conference.with_role(:info_desk, user).pluck(:id) if user.has_role? :info_desk, :any
    # Ids of all the conferences for which the user has a 'volunteer_coordinator' role
    conf_ids_for_volunteer_coordinator =
        Conference.with_role(:volunteer_coordinator, user).pluck(:id) if user.has_role? :volunteer_coordinator, :any

    conf_ids_for_actionable_roles = conf_ids_for_organizer +
                                    conf_ids_for_cfp +
                                    conf_ids_for_info_desk +
                                    conf_ids_for_volunteer_coordinator
    label_roles = Role::LABELS.map { |r| r['name'].parameterize.underscore }

    signed_in(user) # Inherit abilities from signed user
    # User with role
    can [:new, :create], Conference if user.is_admin || (user.has_role? :organizer, :any)
    can [:index, :show, :gallery_photos], Conference
    can :manage, Conference, id: conf_ids_for_organizer
#     can :manage, Conference do |conference|
#       conference.id = conf_ids_for_organizer
#     end
    can :manage, Registration, conference_id: conf_ids_for_organizer + conf_ids_for_info_desk
    can :manage, Question, conference_id: conf_ids_for_organizer + conf_ids_for_info_desk
    cannot [:edit, :update, :destroy], Question, global: true
    can :manage, Vposition, conference_id: conf_ids_for_organizer + conf_ids_for_volunteer_coordinator
    can :manage, Vday, conference_id: conf_ids_for_organizer + conf_ids_for_volunteer_coordinator
    # The ability to manage an Event means that:
    # the user can also edit the schedule and that
    # the user can also vote
    can :manage, Event, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :create, Event
    can :manage, EventType, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :manage, Track, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :manage, DifficultyLevel, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :manage, EmailSettings, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :manage, Lodging, conference_id: conf_ids_for_organizer
    can :manage, Room, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :manage, Sponsor, conference_id: conf_ids_for_organizer
    can :manage, SponsorshipLevel, conference_id: conf_ids_for_organizer
    can :manage, Ticket, conference_id: conf_ids_for_organizer
    can :manage, Target, conference_id: conf_ids_for_organizer
    can :index, Commercial, commercialable_type: 'Conference'
    can :manage, Commercial, commercialable_type: 'Conference', commercialable_id: conf_ids_for_organizer
    # Manage commercials for events that belong to a conference of which user is organizer
    can :manage, Commercial, commercialable_type: 'Event', commercialable_id: Event.where(conference_id: conf_ids_for_organizer + conf_ids_for_cfp).pluck(:id)
    can :manage, Contact, conference_id: conf_ids_for_organizer
    can :manage, Campaign, conference_id: conf_ids_for_organizer
    can :manage, RegistrationPeriod, conference_id: conf_ids_for_organizer
    can :manage, Splashpage, conference_id: conf_ids_for_organizer
    can :manage, CallForPaper, conference_id: conf_ids_for_organizer + conf_ids_for_cfp
    can :manage, Venue, conference_id: conf_ids_for_organizer
    can :index, Venue, conference_id: conf_ids_for_organizer + conf_ids_for_cfp

    # Abilities for Role (Conference resource)
    can :index, Role

    # Can manage conference roles if conference organizer
    can :manage, Role do |role|
      role.resource_type == 'Conference' && (conf_ids_for_organizer.include? role.resource_id)
    end

    # Can add or remove users from role, when user has that same role for the conference
    # Eg. If you are member of the CfP team, you can add more CfP team members (add users to the role 'CfP')
    can [ :add_user, :remove_user], Role do |role|
      role.resource_type == 'Conference' &&
      (Conference.with_role(role.name.parameterize.underscore.to_sym, user).pluck(:id).include? role.resource_id)
    end

    # The user can add role for non-actionable roles, if the user has any actionable role for the conference
    # Eg. A volunteers coordinator can marke users as volunteers, or can marke users as sponsors
    # (But cannot remove them)
    can :add_user, Role do |role|
      role.resource_type == 'Conference' &&
      (conf_ids_for_actionable_roles.include? role.resource_id) &&
      (label_roles.include? role.name)
    end

    # The user can do absolutely anything, if the user is an admin!
    can :manage, :all if user.is_admin
  end

  # Abilities for everyone, even guests (not logged in users)
  def guest
    # can view conferences
    can [:index], Conference
    can [:show], Conference do |conference|
      conference.splashpage && conference.splashpage.public == true
    end
    can [:schedule], Conference do |conference|
      conference.call_for_paper && conference.call_for_paper.schedule_public
    end

    # can view confirmed Events
    can :show, Event do |event|
      event.state == 'confirmed'
    end
    # can view Commercials of confirmed Events
    can :show, Commercial, commercialable_type: 'Event', commercialable_id: Event.where(state: 'confirmed').pluck(:id)
    # can view others
    can :show, User
  end

  def signed_in(user)
    guest # Inherits abilities of guest

    # subscribe, unsubscribe to a Conference
    can [:create, :destroy], Subscription, user_id: user.id

    # can manage their own Registration
    can :manage, Registration, user_id: user.id
    can :index, Ticket
    can :manage, TicketPurchase, user_id: user.id

    # can manage their own User
    can :manage, User, id: user.id
    cannot :index, User

    # can manage their own Event
    can :manage, Event, id: user.events.pluck(:id)
    # can submit Events for conferences that are not over yet
    can :create, Event, conference_id: Conference.where('end_date >= ?', Date.today).pluck(:id)
    # can manage their own commercials
    can :manage, Commercial, commercialable_type: 'Event', commercialable_id: user.events.pluck(:id)
  end
end
