class Admin::AssuranceOptionsService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def assurance_options
    @assurance_options ||= resource_scope.paginate(page: params[:page], per_page: 30)
  end

  private

  def resource_scope
    community.assurance_options
  end
end