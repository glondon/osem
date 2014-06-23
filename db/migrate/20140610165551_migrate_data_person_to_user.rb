class MigrateDataPersonToUser < ActiveRecord::Migration
  class TempPerson < ActiveRecord::Base
    self.table_name = 'people'
  end

  class TempUser < ActiveRecord::Base
    self.table_name = 'users'
  end

  def change
    TempPerson.all.each do |p|
      user = TempUser.find(p.user_id)
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
