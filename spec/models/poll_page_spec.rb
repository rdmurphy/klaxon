require 'rails_helper'

RSpec.describe PollPage do
  include ActiveSupport::Testing::TimeHelpers

  it "creates a snapshot without memoizing html on the page instance" do
    url = "http://example.com/page"
    stub_request(:get, url).to_return(
      status: 200,
      body: "<html><body><div class='watched'>updated copy</div></body></html>"
    )

    page = create(:page, url: url, css_selector: ".watched")

    expect {
      described_class.perform(page: page)
    }.to change { PageSnapshot.where(page: page).count }.by(1)

    snapshot = PageSnapshot.where(page: page).order("created_at DESC").first

    expect(snapshot.html).to include("updated copy")
    expect(snapshot.sha2_hash).to eq Digest::SHA256.hexdigest("updated copy")
    expect(page.instance_variable_defined?(:@html)).to be false
  end

  it "touches an existing snapshot when the watched content is unchanged" do
    url = "http://example.com/page"
    body = "<html><body><div class='watched'>same copy</div></body></html>"
    stub_request(:get, url).to_return(status: 200, body: body)

    page = create(:page, url: url, css_selector: ".watched")
    snapshot = create(
      :page_snapshot,
      page: page,
      html: body,
      sha2_hash: Digest::SHA256.hexdigest("same copy")
    )
    snapshot.update_columns(updated_at: 2.hours.ago)

    travel_to Time.current.change(usec: 0) do
      expect {
        described_class.perform(page: page)
      }.not_to change { PageSnapshot.where(page: page).count }

      expect(snapshot.reload.updated_at).to eq Time.current
    end
  end
end
