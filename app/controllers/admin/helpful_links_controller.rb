class Admin::HelpfulLinksController < Admin::AdminBaseController
  before_action :set_helpful_link, only: [:update, :destroy]

  def create
    result = admin_section_service.create('HelpfulLink', helpful_link_params)
    render json: result
  end

  def update
    result = admin_section_service.update(@helpful_link, helpful_link_params)
    render json: result
  end

  private
  def helpful_link_params
    params.require(:helpful_link)
      .permit(:heading, :enabled)
  end

  def set_helpful_link
    @helpful_link = HelpfulLink.find params[:id]
  end

  def admin_section_service
    @admin_section_service ||= Admin::SectionService.new(@current_online_store)
  end
end