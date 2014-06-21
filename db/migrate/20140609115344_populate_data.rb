class PopulateData < ActiveRecord::Migration
  def up
    # Create users
    user_admin = User.new(email: 'admin@email.com', password: Devise.friendly_token[0,20], name: 'admin name')
    user_admin.skip_confirmation!
    user_admin.save!

    10.times do |i|
      user = User.new(email: "user#{i}@email.com", password: Devise.friendly_token[0,20], name: "name#{i}")
      user.skip_confirmation!
      user.save!
    end

    # Create venues
    5.times do |i|
      Venue.create!(name: "venuename#{i}", address: "address of venue#{i}", website: "www.venue#{i}.eu", description: "description for venue#{i} which could be longer")
    end

    # Create conferences
    10.times do |i|

      conference = Conference.create!(title: "MyConference#{i}", short_title: "conf#{i}", social_tag: "tagconf#{i}", contact_email: "conf#{i}@email.com", timezone: 'Amsterdam', start_date: Date.today + 1*i, end_date: Date.today + 1*i + i)

      conference.venue = Venue.find(i/2 + 1)
    end

    # Create event types
    Conference.all.each do |c|
      5.times do |i|
        eventtype = EventType.new(title: "type#{i} conf#{c.id}", length: i * 10 + 15, minimum_abstract_length: i+1, maximum_abstract_length: i + 20)

        eventtype.conference_id = c.id
        eventtype.save!
      end
    end

    # Create difficulty levels
    Conference.all.each do |c|
      5.times do |i|
        difficulty_level = DifficultyLevel.new(title: "DiffLvl#{i} conf#{c.id}", description: "Description for difflvl#{i}")

        difficulty_level.conference_id = c.id
        difficulty_level.save!
      end
    end

    # Create events
    Conference.all.each do |c|
      10.times do |i|
        user = User.find(i+2)
        user.biography = "biography for user with id #{user.id}"
        user.save!

        event = Event.new(title: "Event #{i} for conf #{c.id}", require_registration: i/2 > 2 ? true : false)

        event.conference = c
        event.event_type_id = c.event_types[i/2].id
        event.difficulty_level_id = c.difficulty_levels[i/2].id
        event.abstract = "Abstract for my talk with title Event#{i} for the conference#{c.id}"

        event.event_users.new(user: user, event_role: 'submitter')
        event.save!
      end
    end

    # Create call for papers
    Conference.all.each do |c|
      cfp= CallForPapers.new(start_date: Date.today, end_date: Date.today + c.id + 20, description: "description for cfp of conference #{c.id}")
      cfp.conference_id = c.id
      cfp.save!
    end
  end

end
