module WatchedContent
  module_function

  def download(url:, page_id: nil)
    return "" if url.blank?

    page_log = page_id.nil? ? "" : " for page.id=#{page_id}"
    Rails.logger.info "downloading url=#{url}#{page_log}"

    dirty = Net::HTTP.get(URI(url.to_s))
    SafeString.coerce(dirty)
  end

  def document(html:)
    Nokogiri::HTML(html.to_s)
  end

  def match_text(html:, css_selector:, exclude_selector: nil)
    match = document(html: html).css(css_selector.to_s.strip)

    if exclude_selector.present?
      match.css(exclude_selector.to_s.strip).each do |node|
        node.content = ""
      end
    end

    match.text
  end

  def match_html(html:, css_selector:)
    document(html: html).css(css_selector.to_s.strip).to_html
  end
end
