class CreateEventUsers < ActiveRecord::Migration
  def change
    create_table :event_users do |t|
      t.references :user
      t.references :event
      t.string :event_role, null: false, default: 'participant'
      t.string :comment

      t.timestamps
    end

    EventPerson.all.each do |ep|
      record = EventUser.new
      record.event_id = ep.event_id
      record.user_id = ep.person.user_id
      record.event_role = ep.event_role
      record.comment = ep.comment
      record.save!
    end

    drop_table :event_people
  end
end
