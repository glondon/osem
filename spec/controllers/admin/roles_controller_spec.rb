require 'spec_helper'

describe Admin::RolesController do

  # It is necessary to use bang version of let to build roles before user
  let(:conference) { create(:conference) }
  let!(:first_user) { create(:user) }
  let!(:organizer_role) { create(:role, name: 'organizer', resource: conference) }
  let!(:admin) { create(:admin, role_ids: organizer_role.id) }

  let(:organizer) { create(:user, role_ids: organizer_role.id) }
  let(:organizer2) { create(:user, email: 'organizer2@email.osem', role_ids: organizer_role.id) }
  let!(:user1) { create(:user) }
  let!(:user2) { create(:user) }

  describe 'GET #index' do
      before(:each) do
        sign_in(admin)
        get :index, conference_id: conference.short_title
      end

      it 'assigns default value to selection variable' do
        expect(assigns(:selection)).to eq 'organizer'
      end

      it 'finds the correct role' do
        expect(assigns(:role)).to eq organizer_role
      end
  end

    describe 'GET #show' do
      before(:each) do
        sign_in(admin)
        xhr :get, :show, conference_id: conference.short_title,
                         id: 'organizer'
      end

      it 'assigns correct value to selection variable' do
        expect(assigns(:selection)).to eq 'organizer'
      end

      it 'assigns correct value to role variable' do
        expect(assigns(:role)).to eq organizer_role
      end

      it 'assigns correct value to role variable (when there is no db entry )' do
        xhr :get, :show, conference_id: conference.short_title,
                         id: 'cfp'

        expect(assigns(:role)).to eq nil
      end
    end

    describe 'PATCH #add_user' do
      before(:each) do
        sign_in(admin)
        patch :add_user, conference_id: conference.short_title,
                         role: { user: { id: user1.id } },
                         id: 'organizer'
      end

      it 'finds correct user' do
        expect(assigns(:user)).to eq user1
      end

      it 'assigns role to user' do
        expect(user1.roles).to eq [organizer_role]
      end

      it 'adds second user' do
        patch :add_user, conference_id: conference.short_title,
                         role: { user: { id: user2.id } },
                         id: 'cfp'

        cfp_role = Role.find_by(name: 'cfp', resource: conference)
        expect(user2.roles).to eq [cfp_role]
      end

      it 'assigns second role to user' do
        patch :add_user, conference_id: conference.short_title,
                         role: { user: { id: user1.id } },
                         id: 'cfp'

        cfp_role = Role.find_by(name: 'cfp', resource: conference)
        expect(user1.roles).to eq [organizer_role, cfp_role]
      end
    end

    describe 'PATCH #remove_user' do
      before(:each) do
        sign_in(admin)
        patch :remove_user, conference_id: conference.short_title,
                            user_id: organizer2.id,
                            id: 'organizer'
      end

      it 'assigns correct value to selection variable' do
        expect(assigns(:selection)).to eq 'organizer'
      end

      it 'removes role from user' do
        organizer2.reload
        expect(organizer2.roles).to eq []
      end

      it 'removes second role from user' do
        # Add cfp role
        organizer2.add_role :organizer, conference # Because it is removed in before(:each)
        organizer2.add_role :cfp, conference
        cfp_role = Role.find_by(name: 'cfp', resource: conference)

        # Remove role organizer
        patch :remove_user, conference_id: conference.short_title,
                            user_id: organizer2.id,
                            id: 'organizer'

        organizer2.reload
        expect(organizer2.roles).to include cfp_role
        expect(organizer2.roles.first).to eq cfp_role
        expect(organizer2.roles.count).to eq 1

        patch :remove_user, conference_id: conference.short_title,
                            user_id: organizer2.id,
                            id: 'cfp'
        organizer2.reload
        expect(organizer2.roles).to eq []
      end
    end
end
