class Admin::TaxesService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def taxes
    @taxes ||= resource_scope.paginate(page: params[:page], per_page: 30)
  end

  private

  def resource_scope
    community.taxes
  end
end