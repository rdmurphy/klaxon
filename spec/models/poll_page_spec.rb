require 'rails_helper'

RSpec.describe PollPage do
  include ActiveSupport::Testing::TimeHelpers

  it "creates a snapshot and returns it without memoizing html on the page instance" do
    url = "http://example.com/page"
    stub_request(:get, url).to_return(
      status: 200,
      body: "<html><body><div class='watched'>updated copy</div></body></html>"
    )

    page = create(:page, url: url, css_selector: ".watched")

    result = nil
    expect {
      result = described_class.perform(page: page)
    }.to change { PageSnapshot.where(page: page).count }.by(1)

    expect(result).to be_a(PageSnapshot)
    expect(result.html).to include("updated copy")
    expect(result.sha2_hash).to eq Digest::SHA256.hexdigest("updated copy")
    expect(page.instance_variable_defined?(:@html)).to be false
  end

  it "touches an existing snapshot and returns false when content is unchanged" do
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
      result = nil
      expect {
        result = described_class.perform(page: page)
      }.not_to change { PageSnapshot.where(page: page).count }

      expect(result).to be false
      expect(snapshot.reload.updated_at).to eq Time.current
    end
  end

  it "excludes content matching exclude_selector from the hash" do
    url = "http://example.com/page"
    body_with_ad = "<html><body><div class='watched'>main content<span class='ad'>buy stuff</span></div></body></html>"
    body_ad_changed = "<html><body><div class='watched'>main content<span class='ad'>buy other stuff</span></div></body></html>"

    page = create(:page, url: url, css_selector: ".watched", exclude_selector: ".ad")

    stub_request(:get, url).to_return(status: 200, body: body_with_ad)
    described_class.perform(page: page)

    stub_request(:get, url).to_return(status: 200, body: body_ad_changed)

    expect {
      described_class.perform(page: page)
    }.not_to change { PageSnapshot.where(page: page).count }
  end

  it "raises when the network request fails" do
    url = "http://example.com/page"
    stub_request(:get, url).to_timeout

    page = create(:page, url: url, css_selector: ".watched")

    expect {
      described_class.perform(page: page)
    }.to raise_error(Net::OpenTimeout)
  end
end
