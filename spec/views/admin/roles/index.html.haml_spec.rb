require 'spec_helper'

describe 'admin/roles/index' do
  let(:conference) { create(:conference) }

  before(:each) do
    assign :conference, conference
    assign :actionables, [{'name' => 'Organizer', 'description' => 'The organizer of the conference - has full access'},
                          {'name' => 'CfP', 'description' => 'Members of the CfP team'}]
    assign :labels, ['Attendee', 'Volunteer', 'Speaker', 'Sponsor', 'Press', 'Keynote Speaker']
    render
  end

  it 'renders index' do
    expect(rendered).to have_link('Organizer', href: "/admin/conference/#{conference.short_title}/roles/organizer")
    expect(rendered).to have_link('CfP', href: "/admin/conference/#{conference.short_title}/roles/cfp")
    expect(rendered).to include('The organizer of the conference - has full access')
    expect(rendered).to include('Members of the CfP team')
  end
end
