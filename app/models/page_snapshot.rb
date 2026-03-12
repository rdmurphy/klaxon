class PageSnapshot < ApplicationRecord
  belongs_to :page
  has_many :changes_as_before, class_name: "Change", as: :before
  has_many :changes_as_after, class_name: "Change", as: :after

  scope :without_changes, -> { where.missing(:changes_as_before).where.missing(:changes_as_after) }

  validates :sha2_hash, presence: true

  after_destroy do |record|
    Change.destroy_related(record)
  end

  def document
    WatchedContent.document(html: html)
  end

  def match_text
    WatchedContent.match_text(
      html: html,
      css_selector: self.page.css_selector,
      exclude_selector: self.page.exclude_selector
    )
  end

  def display_hash
    sha2_hash.first(8)
  end

  def previous
    siblings.where("created_at < ?", self.created_at).order("created_at DESC").first
  end

  def siblings
    parent.page_snapshots.where.not(id: self.id)
  end

  def parent
    self.page
  end

  def blank_match_text?
    self.match_text.blank?
  end

  def filename
    self.page.name.gsub(" ", "-") + "-" + self.created_at.to_s.gsub(" ", "-") + ".html"
  end
end
