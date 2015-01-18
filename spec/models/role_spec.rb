require 'spec_helper'

describe Role do
  let(:conference) { create(:conference) }
  let!(:organizer_role) { create(:role, name: 'organizer', resource: conference) }
  let!(:cfp_role) { create(:role, name: 'cfp', resource: conference) }
  let!(:organizer) { create(:user, role_ids: organizer_role.id) }

  it 'get_users' do
    expect(organizer_role.users).to include organizer
    expect(organizer_role.users.count).to eq 1
    expect(cfp_role.users).to eq []
  end
end
