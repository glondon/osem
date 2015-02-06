require 'spec_helper'

describe 'admin/roles/show' do
  let(:conference) { create(:conference) }
  let(:organizer_role) { create(:organizer_role, description: 'My description for organizer role', resource: conference) }
  let(:organizer) { create(:user, name: 'test name', email: 'test@email.osem', role_ids: [organizer_role.id]) }

  before(:each) do
    assign :conference, conference
    assign :selection, 'organizer'
    assign :role, organizer_role
    assign :role_users, 'organizer' => [organizer]
    assign :actionables, [{'name' => 'Organizer', 'description' => 'The organizer of the conference - has full access'}, {'name' => 'CfP', 'description' => 'Members of the CfP team'}]
    assign :labels, ['Attendee', 'Volunteer', 'Speaker', 'Sponsor', 'Press', 'Keynote Speaker']
    render
  end

  it 'renders index' do
    expect(rendered).to include(organizer_role.name)
    expect(rendered).to include('Add user:')
    expect(rendered).to include('Select user')
    expect(rendered).to have_selector('table thead th:nth-of-type(1)', text: 'ID')
    expect(rendered).to have_selector('table thead th:nth-of-type(2)', text: 'Name')
    expect(rendered).to have_selector('table thead th:nth-of-type(3)', text: 'Email')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(1)', text: organizer.id)
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(2)', text: 'test name')
    expect(rendered).to have_selector('table tbody tr:nth-of-type(1) td:nth-of-type(3)', text: 'test@email.osem')
  end
end
