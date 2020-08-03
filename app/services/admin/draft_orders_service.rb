class Admin::DraftOrdersService
  attr_reader :community, :params

  def initialize(community:, params:)
    @params = params
    @community = community
  end

  def orders
    @orders ||= resource_scope
  end

  private

  def resource_scope
    community.transactions
  end

  def sort_column
    case params[:sort]
    when 'draft'
      'id'
    when 'date'
      'created_at'
    end
  end

  def sort_direction
    if params[:direction] == "asc"
      "asc"
    else
      "desc" #default
    end
  end
end
