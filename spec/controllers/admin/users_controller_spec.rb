require 'spec_helper'
describe Admin::UsersController do
  let!(:admin_role) { create(:admin_role) }
  let!(:participant_role) { create(:participant_role) }
  let(:admin) { create(:admin) }
  let(:user) { create(:user) }
  before(:each) do
    sign_in(admin)
  end
  describe 'GET #index' do
    it 'populates an array of users' do
      user1 = create(:user, email: 'gopesh.7500@gmail.com')
      user2 = create(:user, email: 'gopesh_750@gmail.com')
      get :index
      expect(assigns(:users)).to match_array([user, admin, user1, user2])
    end
    it 'renders index template' do
      get :index
      expect(response).to render_template :index
    end
  end
  describe 'PATCH #update' do
    context 'valid attributes' do
      it 'locates requested @user' do
        patch :update, id: user.id
        expect(build(:user, id: user.id)).to eq(user)
      end
      it 'changes @users attributes' do
        patch :update, id: user.id
        expect(build(
          :user, email: 'example@incoherent.de', id: user.id).email).
              to eq('example@incoherent.de')
      end
      it "redirects to the updated user" do
        patch :update, id: user.id
        expect(response).to redirect_to admin_users_path
      end
    end
  end
  describe 'DELETE #destroy' do
    before :each do
      @user = create(:user)
      @event = create(:event)
      @user_event = @event.submitter
      @event_scheduled = create(:event, start_time: Time.now)
      @user_event_scheduled = @event_scheduled.submitter
      @voter = create(:user)
      create(:vote, user: @voter, event: @event)
      @event2 = create(:event)
      @voter_with_events = @event2.submitter
      create(:vote, user: @voter_with_events, event: @event)
    end

    context 'valid attributes' do
      it 'it deletes the contact' do ###
        expect { delete :destroy, id: @user.id }.to change(User, :count).by(-1)
      end
      it 'redirects to users#index' do
        delete :destroy, id: @user
        expect(response).to redirect_to admin_users_path
      end
    end

    context 'deletes users' do
      it 'when user does not have events' do
        expect { delete :destroy, id: @user.id }.to change(User, :count).by(-1)
      end

      it 'when user has unscheduled events' do
        expect { delete :destroy, id: @user_event.id }.to change(User, :count).by(-1)
      end
    end

    context 'does not delete users' do
      it 'when user has voted on proposals' do
        expect { delete :destroy, id: @voter.id }.to change(User, :count).by(0)
        expect { delete :destroy, id: @voter_with_events.id}.to change(User, :count).by(0)
      end

      it 'when user has scheduled events' do
        expect { delete :destroy, id: @user_event_scheduled.id }.to change(User, :count).by(0)
        expect(@user_event_scheduled.reload.name).to eq('User deleted')
      end
    end
  end
end
