class Admin::PagesService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def pages
    @pages ||= resource_scope.paginate(page: params[:page], per_page: 30)
  end

  private

  def resource_scope
    community.pages
  end
end