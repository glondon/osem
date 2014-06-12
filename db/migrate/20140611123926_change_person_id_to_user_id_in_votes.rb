class ChangePersonIdToUserIdInVotes < ActiveRecord::Migration
  def change
    add_column :votes, :user_id, :integer

    Vote.all.each do |v|
      v.user_id = v.person.user_id
      v.save!
    end

    remove_column :votes, :person_id
  end
end
