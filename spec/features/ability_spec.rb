require 'spec_helper'

feature 'Display menu properly' do
  # It is necessary to use bang version of let to build roles before user
  let(:conference1) { create(:conference) } # user is organizer
  let(:conference2) { create(:conference) } # user is cfp
  let(:conference3) { create(:conference) } # user is info_desk
  let(:conference4) { create(:conference) } # user is volunteer coordinator
  let(:conference5) { create(:conference) } # user has no role

  let(:role_organizer) { create(:role, name: 'organizer', resource: conference1) }
  let(:role_cfp) { create(:role, name: 'cfp', resource: conference2) }
  let(:role_info_desk) { create(:role, name: 'info_desk', resource: conference3) }
  let(:role_volunteer_coordinator) { create(:role, name: 'volunteer_coordinator', resource: conference4) }

  let(:user) { create(:user, role_ids: [role_cfp.id, role_organizer.id, role_cfp.id, role_info_desk.id, role_volunteer_coordinator.id]) }

  scenario 'when user is organizer' do
    sign_in user
    visit admin_conference_path(conference1.short_title)

#     click_link 'SETTINGS'
#     expect(current_path).to eq(edit_admin_conference_path(conference.short_title))

    expect(page.has_content?('SETTINGS')).to be true
    expect(page.has_content?('MANAGE')).to be true
    expect(page.has_content?('Registrations')).to be true
    expect(page.has_content?('Events')).to be true
    expect(page.has_content?('Schedule')).to be true
    expect(page.has_content?('Campaigns')).to be true
    expect(page.has_content?('Targets')).to be true
    expect(page.has_content?('Venue')).to be true
    expect(page.has_content?('Sponsorship')).to be true
    expect(page.has_content?('Supporter Levels')).to be true
    expect(page.has_content?('Emails')).to be true
    expect(page.has_content?('Call for papers')).to be true
    expect(page.has_content?('Questions')).to be true
    expect(page.has_content?('Commercials')).to be true
  end

  scenario 'when user is cfp' do
    sign_in user
    visit admin_conference_path(conference2.short_title)

    expect(page.has_content?('SETTINGS')).to be false
    expect(page.has_content?('MANAGE')).to be true
    expect(page.has_content?('Registrations')).to be false
    expect(page.has_content?('Events')).to be true
    expect(page.has_content?('Schedule')).to be true
    expect(page.has_content?('Campaigns')).to be false
    expect(page.has_content?('Targets')).to be false
    expect(page.has_content?('Venue')).to be false
    expect(page.has_content?('Sponsorship')).to be false
    expect(page.has_content?('Supporter Levels')).to be false
    expect(page.has_content?('Emails')).to be true
    expect(page.has_content?('Call for papers')).to be true
    expect(page.has_content?('Questions')).to be false
    expect(page.has_content?('Commercials')).to be false
  end

  scenario 'when user is info desk' do
    sign_in user
    visit admin_conference_path(conference3.short_title)

    expect(page.has_content?('SETTINGS')).to be false
    expect(page.has_content?('MANAGE')).to be true
    expect(page.has_content?('Registrations')).to be true
    expect(page.has_content?('Events')).to be false
    expect(page.has_content?('Schedule')).to be false
    expect(page.has_content?('Campaigns')).to be false
    expect(page.has_content?('Targets')).to be false
    expect(page.has_content?('Venue')).to be false
    expect(page.has_content?('Sponsorship')).to be false
    expect(page.has_content?('Supporter Levels')).to be false
    expect(page.has_content?('Emails')).to be false
    expect(page.has_content?('Call for papers')).to be false
    expect(page.has_content?('Questions')).to be true
    expect(page.has_content?('Commercials')).to be false
  end

  scenario 'when user is volunteer coordinator' do
    sign_in user
    visit admin_conference_path(conference4.short_title)

    expect(page.has_content?('SETTINGS')).to be false
    expect(page.has_content?('MANAGE')).to be true
    expect(page.has_content?('Registrations')).to be false
    expect(page.has_content?('Events')).to be false
    expect(page.has_content?('Schedule')).to be false
    expect(page.has_content?('Campaigns')).to be false
    expect(page.has_content?('Targets')).to be false
    expect(page.has_content?('Venue')).to be false
    expect(page.has_content?('Sponsorship')).to be false
    expect(page.has_content?('Supporter Levels')).to be false
    expect(page.has_content?('Emails')).to be false
    expect(page.has_content?('Call for papers')).to be false
    expect(page.has_content?('Questions')).to be false
    expect(page.has_content?('Commercials')).to be false
  end
end
