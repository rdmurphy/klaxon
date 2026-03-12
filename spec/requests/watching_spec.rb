require 'rails_helper'

RSpec.describe "Watching" do
  describe "GET /" do
    before { login }

    context "with no pages or changes" do
      it "shows the bookmarklet onboarding" do
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("Watch Your First Item")
      end
    end

    context "with an initial snapshot and no changes" do
      it "shows the page as started being watched" do
        snapshot = create(:page_snapshot)
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("started being watched")
        expect(response.body).to include(snapshot.page.name)
      end
    end

    context "with a change" do
      it "shows the page as changed" do
        snapshot = create(:page_snapshot)
        Change.create!(
          before_type: "PageSnapshot", before_id: snapshot.id,
          after_type: "PageSnapshot", after_id: snapshot.id
        )
        get root_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include("changed")
      end

      it "does not also show the before snapshot as started being watched" do
        before_snapshot = create(:page_snapshot)
        after_snapshot = create(:page_snapshot, page: before_snapshot.page)
        Change.create!(
          before_type: "PageSnapshot", before_id: before_snapshot.id,
          after_type: "PageSnapshot", after_id: after_snapshot.id
        )
        get root_path
        expect(response.body).not_to include("started being watched")
      end
    end

    context "with both initial snapshots and changes" do
      it "shows both and sorts by created_at descending" do
        old_snapshot = create(:page_snapshot)
        old_snapshot.update_column(:created_at, 2.days.ago)

        new_snapshot = create(:page_snapshot)

        Change.create!(
          before_type: "PageSnapshot", before_id: old_snapshot.id,
          after_type: "PageSnapshot", after_id: old_snapshot.id,
          created_at: 1.day.ago
        )

        get root_path
        expect(response).to have_http_status(:success)

        new_snapshot_pos = response.body.index(new_snapshot.page.name)
        old_snapshot_pos = response.body.rindex(old_snapshot.page.name)

        expect(new_snapshot_pos).to be < old_snapshot_pos
      end
    end
  end
end
