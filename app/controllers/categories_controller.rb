class CategoriesController < ApplicationController
  def index
    @listings = listing_service.index(params)
    @listings = @listings.paginate(page: params[:page], per_page: 25)
    @total_pages = @listings.total_pages
    redirect_url = categories_path(sort_condition: params[:sort_condition])
    respond_to do |format|
      format.html
      format.json {render json: {redirect_url: redirect_url}}
    end
  end

  def search_result_page

  end

  private

  def listing_service
    @listing_service ||= ListingService.new()
  end
end
