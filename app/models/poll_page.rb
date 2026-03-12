module PollPage
  BATCH_SIZE = 100

  module_function

  def perform(page: nil)
    html = WatchedContent.download(url: page.url, page_id: page.id)
    match_text = WatchedContent.match_text(
      html: html,
      css_selector: page.css_selector,
      exclude_selector: page.exclude_selector
    )
    sha2_hash = Digest::SHA256.hexdigest(match_text)

    # TODO: this will not catch changes if a page goes
    # from state A to state B, then back to state A, as state A already is recorded
    # perhaps this should check if the current sha2 is not equal to the most recent page_snapshot?
    existing = PageSnapshot.find_by(page: page, sha2_hash: sha2_hash)

    if existing
      existing.touch
      puts "page id='#{page.id}' has not changed"
      return false
    end

    PageSnapshot.create(page: page, sha2_hash: sha2_hash, html: html)
  end

  def perform_all(batch_size: BATCH_SIZE)
    Page.ids.shuffle.each_slice(batch_size) do |page_ids|
      pages_by_id = Page.where(id: page_ids).index_by(&:id)

      page_ids.each do |page_id|
        page = pages_by_id[page_id]
        next if page.nil?

        begin
          self.perform(page: page)
        rescue StandardError => e
          # TODO: send notifications about failed updates?
          puts "Failed to update page #{page.id}", e
        end
      end
    end
  end
end
