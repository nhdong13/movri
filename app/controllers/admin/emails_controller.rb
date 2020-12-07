class Admin::EmailsController < Admin::AdminBaseController
  before_action :set_email, only: :update

  def new
    @selected_tribe_navi_tab = "admin"
    @selected_left_navi_link = "email_members"
    @display_knowledge_base_articles = APP_CONFIG.display_knowledge_base_articles
    @knowledge_base_url = APP_CONFIG.knowledge_base_url
  end

  def create
    content = params[:email][:content].gsub(/[”“]/, '"') if params[:email][:content] # Fi  UTF-8 quotation marks
    if params[:test_email] == '1'
      Delayed::Job.enqueue(CommunityMemberEmailSentJob.new(@current_user.id, @current_user.id, @current_community.id, content, params[:email][:locale], true))
      render body: t("admin.emails.new.test_sent"), layout: false
    else
      email_job = CreateMemberEmailBatchJob.new(@current_user.id, @current_community.id, content, params[:email][:locale], params[:email][:recipients])
      Delayed::Job.enqueue(email_job)
      flash[:notice] = t("admin.emails.new.email_sent")
      redirect_to :action => :new
    end
  end

  def update
    if @email.update_attributes(email_params)
      redirect_to edit_admin_community_draft_order_path(@email.community_id, params[:transaction_id])
    end
  end

  def review_email
    @transaction = Transaction.find_by(id: params[:transaction_id])

    respond_to do |format|
      format.js { render layout: false }
    end
  end

  def sent_invoice_email
    transaction = Transaction.find_by(id: params[:transaction_id])
    payment_path =  payment_transaction_url(transaction.uuid_object)
    SendgridMailer.new(transaction, nil, nil, false).send_invoice_mail(params[:to], payment_path)
  end

  protected

  ADMIN_EMAIL_OPTIONS = [:all_users, :posting_allowed, :with_listing, :with_listing_no_payment, :with_payment_no_listing, :no_listing_no_payment]

  def admin_email_options
    options = ADMIN_EMAIL_OPTIONS.dup
    options.delete(:posting_allowed) unless @current_community.require_verification_to_post_listings
    options.map{|option| [I18n.t("admin.emails.new.recipients.options.#{option}"), option] }
  end

  helper_method :admin_email_options

  private

  def set_email
    @email = Email.find(params[:id])
  end

  def email_params
    params.require(:email).permit(:address)
  end
end
