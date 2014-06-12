class MigrateDataPersonToUser < ActiveRecord::Migration
  def change
    Person.all.each do |p|
      user = User.find(p.user_id)
      user.name = "#{p.public_name}"
      user.save!
    end
    drop_table :people
  end
end
