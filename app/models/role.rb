class Role < ActiveRecord::Base
  attr_accessible :name, :description, :resource

  belongs_to :resource, polymorphic: true
  has_and_belongs_to_many :users

  before_create :set_description

  scopify

  LABELS = {'name' => 'Attendee', 'description' => 'For the attendees of the conference'},
           {'name' => 'Volunteer', 'description' => 'For the volunteers of the conference'},
           {'name' => 'Speaker', 'description' => 'For the speaker of the conference'},
           {'name' => 'Sponsor', 'description' => 'For the sponsor of the conference'},
           {'name' => 'Press', 'description' => 'For the press personnel at the conference'},
           {'name' => 'Keynote Speaker', 'description' => 'For the keynote speakers of the conference'}

  ACTIONABLES = {'name' => 'Organizer', 'description' => 'For the organizers of the conference (who shall have full access)'},
                {'name' => 'CfP', 'description' => 'For the members of the CfP team'},
                {'name' => 'Info Desk', 'description' => 'For the members of the Info Desk team'},
                {'name' => 'Volunteers Coordinator', 'description' => 'For the people in charge of volunteers'}

  validates :name, presence: true

  ##
  # Retrieves the description of the role, regardless if it is a label or a custom table entry
  #
  # ====Args
  # * +role+ -> The role we check for in original format
  # * +resource+ -> The resource of the role, ie Conference.first
  # ====Returns
  # * +text+ -> The description of the role
  def self.get_description(role, resource)
    r = Role.find_by(name: role.parameterize.underscore, resource: resource)
    if r
      return r.description
    else
      return LABELS.find { |l| l['name'] == role}['description']
    end
  end

  ##
  # Retrieves the users that have the given role
  #

  # * +role+ -> The role we check for in ActiveRecord format
  # ====Returns
  # * +[]+ -> Returns blank Array when the role table record does not exist
  # * +ActiveRecord CollectionProxy+ -> Returns the users of the role, when there is a table entry
  def self.get_users(role)
    if role.blank?
      return []
    else
      return role.users
    end
  end

  private

  ##
  # Sets the description attribute of the role, based on the description variable in the hash
  # Is executed before creation
  # ====Args
  # (None)
  # ====Returns
  # The value of the description attribute for the newly initialized Role object
  def set_description
    (Role::LABELS + Role::ACTIONABLES).each do |role|
      if self.name.titleize == role['name']
        self.description = role['description']
      end
    end
  end
end
