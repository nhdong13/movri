class OnlineStore::SectionsPresenter
  attr_reader :online_store

  def initialize(online_store)
    @online_store = online_store
  end

  def featured_products
    online_store.sections.featured_products
  end

  def store_grids
    online_store.sections.store_grids
  end

  def header
    online_store.header
  end

  def slideshow
    online_store.slideshow
  end

  def highlight_banner
    online_store.highlight_banner
  end

  def store_footers
    online_store.sections.store_footers
  end

  def footer_helpful_links
    online_store.sections.helpful_links
  end
end