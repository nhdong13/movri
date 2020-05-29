class CategoriesController < ApplicationController
  def index
    @listings = Listing.all
    @listings = @listings.paginate(page: params[:page], per_page: 4)
    respond_to do |format|
      format.html
      format.js { render layout: false }
    end
  end
end
