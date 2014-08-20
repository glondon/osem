class FixWrongMigrationAddUsersToEvents < ActiveRecord::Migration
  class TempEvent < ActiveRecord::Base
    self.table_name = 'events'
  end

  class TempEventUser < ActiveRecord::Base
    self.table_name = 'event_users'
    belongs_to :temp_event
    belongs_to :temp_user
    attr_accessible :event_id, :user_id, :event_role
  end


  class Version < ActiveRecord::Base
    self.table_name = 'versions'
  end

  def change
    user_deleted = User.find_by(email: 'deleted@localhost.osem')

    TempEvent.all.each do |event|
      whodunnit = Version.find_by(item_type: 'Event', item_id: event.id, event: 'create').whodunnit
      original_user = User.find_by(id: whodunnit)

      if original_user.blank?
        original_submitter = user_deleted
      else
        original_submitter = original_user
      end

      # Substitute submitter record
      submitter = TempEventUser.find_by(event_id: event.id, event_role: 'submitter')
      submitter.user_id = original_submitter.id
      submitter.save!

      # Substitute speaker record
      speaker = TempEventUser.find_by(event_id: event.id, event_role: 'speaker')
      speaker.user_id = original_submitter.id
      speaker.save!
    end
  end
end
