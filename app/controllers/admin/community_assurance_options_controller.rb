class Admin::CommunityAssuranceOptionsController < Admin::AdminBaseController
  before_action :set_selected_left_navi_link
  before_action :set_service
  before_action :initialize_assurance, only: [:create]

  def index; end

  def new
    @assurance_option = AssuranceOption.new
  end

  def create
    if @assurance_option.save
      redirect_to admin_community_assurance_options_path(@current_community)
    else
      flash[:error] = t("layouts.notifications.create_assurance_option_failed")
    end
  end

  private

  def set_selected_left_navi_link
    @selected_left_navi_link = "assurance_options"
  end

  def set_service
    @service = Admin::AssuranceOptionsService.new(
      community: @current_community,
      params: params)
  end

  def initialize_assurance
    assurance_params = params.require(:assurance_option).permit(
      :title,
      :content,
      :image,
      :visible
    )

    @assurance_option = @current_community.assurance_options.new(assurance_params)
  end
end