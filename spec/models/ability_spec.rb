require 'spec_helper'
require 'cancan/matchers'

describe 'User' do
  describe 'Abilities' do
    subject(:ability){ Ability.new(user) }
    let(:user){ nil }
    let(:conference_not_public) { create(:conference, make_conference_public: false) }
    let(:conference_public) { create(:conference)}
    let(:event_confirmed) { create(:event, state: 'confirmed') }
    let(:someevent) { create(:event) }

    context 'when user is a guest' do  # Test abilities for guest users

      it{ should be_able_to(:show, conference_public)}
      it{ should_not be_able_to(:show, conference_not_public)}

      it{ should be_able_to(:show, event_confirmed)}
      it{ should_not be_able_to(:show, someevent)}

      it{ should be_able_to(:index, :schedule)}

      it{ should_not be_able_to(:create, Event)}
      it{ should_not be_able_to(:manage, Event)}
      it{ should_not be_able_to(:manage, Conference)}
      it{ should_not be_able_to(:manage, :any)}
    end

    context 'when user is a Signed In User' do # Test abilities for signed in users (without any role)
      let(:user) { create(:participant) }
      let(:registration1) { create(:registration, conference: conference_public, user: user) }
      let(:registration2) { create(:registration, conference: conference_not_public, user: user) }


      it{ should be_able_to(:create, Event) }
      it{ should be_able_to(:index, Event) }
      it{ should_not be_able_to(:manage, Event.new) }
      it{ should be_able_to(:show, event_confirmed) }

      it{ should be_able_to(:manage, registration1) }
      it{ should be_able_to(:manage, registration2) }

      it{ should be_able_to(:show, conference_public)}
      it{ should_not be_able_to(:show, conference_not_public)}
      it{ should_not be_able_to(:manage, Conference) }
    end

    context 'user #is_admin?' do
      let(:user) { create(:admin) }
      it{ should be_able_to(:manage, User) }
    end

    context 'signed in users can manage their events' do
      let(:user) { create(:participant) }
      let(:user2) { create(:participant) }
      let(:myevent) { create(:event, users: [user]) }
      let(:someevent) { create(:event, users: [user2]) }

      # Users are able to update and destroy their own events
      it{ should be_able_to(:update, myevent) }
      it{ should be_able_to(:destroy, myevent) }
      it{ should be_able_to(:manage, myevent) }

      # Users are not able to update and destroy other users events
      it{ should_not be_able_to(:update, someevent) }
      it{ should_not be_able_to(:destroy, someevent) }
      it{ should_not be_able_to(:manage, someevent) }
    end

    context 'when user is an organizer' do
      let!(:conference1) { create(:conference) }
      let!(:conference2) { create(:conference) }
      let(:role) { create(:organizer_role, resource: conference1) }
      let(:user) { create(:user, role_ids: [role.id]) }
      let(:someuser) { create(:user) }
      let(:registration1) { create(:registration, user: someuser, conference_id: conference1.id) }

      it{ should be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:manage, conference2) }
      it{ should be_able_to(:manage, registration1) }
      it{ should be_able_to(:create, Registration) }
    end

    context 'when user is part of cfp' do
      let!(:conference1) { create(:conference) }
      let!(:conference2) { create(:conference) }
      let(:role) { create(:role, name: 'cfp', resource: conference1) }
      let(:user) { create(:user, role_ids: role.id) }
      let(:event) { create(:event, conference_id: conference1.id) }
      let(:someevent) { create(:event, conference_id: conference2.id) }
      let(:cfp) { create(:call_for_papers, conference: conference1) }

      it{ should_not be_able_to(:manage, conference1) }
      it{ should_not be_able_to(:manage, conference2) }
      it{ should be_able_to(:index, conference1) }
      it{ should be_able_to(:show, conference1) }

      it{ should be_able_to(:manage, event) }
      it{ should_not be_able_to(:manage, someevent) }

      it{ should be_able_to(:manage, cfp) }
      it{ should be_able_to(:manage, create(:event_type, conference: conference1)) }
    end

    context 'when user has multiple roles' do
      let!(:conference1) { create(:conference) } # user is organizer
      let!(:conference2) { create(:conference) } # user is cfp
      let!(:conference3) { create(:conference) } # user is info_desk
      let!(:conference4) { create(:conference) } # user is volunteer coordinator
      let!(:conference5) { create(:conference) } # user has no role
      let(:role_organizer) { create(:role, name: 'organizer', resource: conference1) }
      let(:role_cfp) { create(:role, name: 'cfp', resource: conference2) }
      let(:user) { create(:user, role_ids: [role_cfp.id, role_organizer.id]) }
      let(:someuser) { create(:user) }
      let(:registration1) { create(:registration, user: someuser, conference_id: conference1.id) }
      let(:registration2) { create(:registration, user: someuser, conference_id: conference2.id) }

      it{ should be_able_to(:manage, conference1) }
      it{ should be_able_to(:manage, registration1) }
      it{ should be_able_to(:manage, conference1.events.new) }
      it{ should be_able_to(:manage, conference2.events.new) }

      it{ should_not be_able_to(:manage, conference2) }
      it{ should_not be_able_to(:manage, registration2) }

#       it 'shows menu correctly' do
#         visit admin_conference_path(conference1.short_title)
#         expect(page.has_content?('SETTINGS')).to be true
#         expect(page.has_content?('MANAGE')).to be true
#         expect(page.has_content?('Registrations')).to be true
#         expect(page.has_content?('Events')).to be true
#         expect(page.has_content?('Schedule')).to be true
#         expect(page.has_content?('Campaigns')).to be true
#         expect(page.has_content?('Targets')).to be true
#         expect(page.has_content?('Venue')).to be true
#         expect(page.has_content?('Sponsorship')).to be true
#         expect(page.has_content?('Supporter Levels')).to be true
#         expect(page.has_content?('Emails')).to be true
#         expect(page.has_content?('Call for papers')).to be true
#         expect(page.has_content?('Questions')).to be true

#         visit admin_conference_path(conference2.short_title)
#         expect(page.has_content?('SETTINGS')).to be true
#         expect(page.has_content?('MANAGE')).to not_be true
#         expect(page.has_content?('Registrations')).to not_be true
#         expect(page.has_content?('Events')).to be true
#         expect(page.has_content?('Schedule')).to be true
#         expect(page.has_content?('Campaigns')).to not_be true
#         expect(page.has_content?('Targets')).to not_be true
#         expect(page.has_content?('Venue')).to be true
#         expect(page.has_content?('Sponsorship')).to not_be true
#         expect(page.has_content?('Supporter Levels')).to not_be true
#         expect(page.has_content?('Emails')).to be true
#         expect(page.has_content?('Call for papers')).to be true
#         expect(page.has_content?('Questions')).to not_be true

#         visit admin_conference_path(conference5.short_title)
#         expect(page.has_content?('SETTINGS')).to not_be true
#         expect(page.has_content?('MANAGE')).to be true
#         expect(page.has_content?('Registrations')).to not_be true
#         expect(page.has_content?('Events')).to not_be true
#         expect(page.has_content?('Schedule')).to not_be true
#         expect(page.has_content?('Campaigns')).to not_be true
#         expect(page.has_content?('Targets')).to not_be true
#         expect(page.has_content?('Venue')).to not_be true
#         expect(page.has_content?('Sponsorship')).to not_be true
#         expect(page.has_content?('Supporter Levels')).to not_be true
#         expect(page.has_content?('Emails')).to not_be true
#         expect(page.has_content?('Call for papers')).to not_be true
#         expect(page.has_content?('Questions')).to not_be true
#       end
    end
  end
end
