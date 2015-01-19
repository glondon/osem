class Role < ActiveRecord::Base
  attr_accessible :name, :description, :resource
  has_and_belongs_to_many :users
  belongs_to :resource, polymorphic: true
  before_create :set_description

  scopify

  LABELS = {'name' => 'Attendee', 'description' => ''},
           {'name' => 'Volunteer', 'description' => ''},
           {'name' => 'Speaker', 'description' => ''},
           {'name' => 'Sponsor', 'description' => ''},
           {'name' => 'Press', 'description' => ''},
           {'name' => 'Keynote Speaker', 'description' => ''}

  ACTIONABLES = {'name' => 'Organizer', 'description' => 'The organizer of the conference - has full access'},
                {'name' => 'CfP', 'description' => 'Members of the CfP team'},
                {'name' => 'Info Desk', 'description' => 'Members of the Info Desk team'},
                {'name' => 'Volunteers Coordinator', 'description' => 'In charge of volunteers'}

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
