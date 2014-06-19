class MigrateDataPersonToUser < ActiveRecord::Migration
  def change
    Person.all.each do |p|
      user = User.find(p.user_id)
      if p.public_name.empty?
        user.name = p.email
      else
        user.name = p.public_name
      end
      user.biography = p.biography
      user.save!
    end
  end
end
