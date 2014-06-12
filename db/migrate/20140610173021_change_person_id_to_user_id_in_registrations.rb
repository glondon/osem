class ChangePersonIdToUserIdInRegistrations < ActiveRecord::Migration
  def change
    add_column :registrations, :user_id, :integer

    Registration.all.each do |r|
      r.user_id = r.person.user_id
      r.save!
    end

    remove_column :registrations, :person_id
  end
end
