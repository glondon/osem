class Tag < ActiveRecord::Base
  scopify

  attr_accessible :name, :description, :resource, :user_ids

  has_and_belongs_to_many :users, join_table: 'users_tags'
  has_and_belongs_to_many :events, join_table: 'events_tags'
  belongs_to :resource, :polymorphic => true

  validates :name, presence: true
  validates_uniqueness_of :name, scope: :resource
end
