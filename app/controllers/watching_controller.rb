class WatchingController < ApplicationController
  before_action :authorize

  def feed
    changes = Change.includes(after: { page: :user }).order(created_at: :desc).limit(20)
    initial_snapshots = PageSnapshot.without_changes.includes(page: :user).order(created_at: :desc).limit(20)
    @feed_items = (changes + initial_snapshots).sort_by(&:created_at).reverse.first(20)
  end
end
