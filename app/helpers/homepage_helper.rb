module HomepageHelper
  def show_subcategory_list(category, current_category_id)
    category.id == current_category_id || category.children.any? do |child_category|
      child_category.id == current_category_id
    end
  end

  def with_first_listing_image(listing, &block)
    Maybe(listing)
      .listing_images
      .map { |images| images.first }[:medium].each { |url|
      block.call(url)
    }
  end

  def without_listing_image(listing, &block)
    if listing.listing_images.size == 0
      block.call
    end
  end

  def format_distance(distance)
    precision = (distance < 1) ? 1 : 2
    (distance < 0.1) ? "< #{number_with_delimiter(0.1, locale: locale)}" : number_with_precision(distance, precision: precision, significant: true, locale: locale)
  end

  def is_homepage?
    params[:controller] == "homepage" && params[:action] == "index"
  end

  def header_on_homepage?(header)
    is_homepage? && header.sticky_enabled? && header.home_only_enabled?
  end

  def header_on_pages?(header)
    header.sticky_enabled? && header.announcement_enabled?
  end

  def grid_styles grid
    case grid.text_alignment
    when 'bottom_center'
      {
        position: 'bottom',
        text_align: 'center'
      }
    when 'top_center'
      {
        position: 'top',
        text_align: 'center'
      }
    else
      {
        position: 'bottom',
        text_align: 'center'
      }
    end
  end
end