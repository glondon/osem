class DropTablesPeopleEventPeople < ActiveRecord::Migration
  def change
    drop_table :event_people
    drop_table :people
  end
end
