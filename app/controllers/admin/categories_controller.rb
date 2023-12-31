class Admin::CategoriesController < Admin::AdminBaseController

  def index
    @selected_left_navi_link = "listing_categories"
    @categories = @current_community.top_level_categories.includes(:translations, children: :translations)
    respond_to do |format|
      format.html
      format.json { render json: {success: true, categories: @categories.as_json(include: :translations)}}
    end
  end

  def new
    @selected_left_navi_link = "listing_categories"
    @category = Category.new
    @category_type = params[:category_type] ? params[:category_type] : 'category'
    shapes = @current_community.shapes
    selected_shape_ids = shapes.map { |s| s[:id] } # all selected by defaults
    render locals: { shapes: shapes, selected_shape_ids: selected_shape_ids }
  end

  def create
    @selected_left_navi_link = "listing_categories"
    @category = Category.new(category_params)
    @category.community = @current_community
    @category.parent_id = nil if params[:category][:parent_id].blank?
    if @category.parent
      if @category.parent.category_type == 'category'
        @category_type = 'subcategory'
      elsif @category.parent.category_type == 'subcategory'
        @category_type = 'children_category'
      else
        @category_type = 'category'
      end
    end
    @category.sort_priority = Admin::SortingService.next_sort_priority(@current_community.categories)
    shapes = @current_community.shapes
    selected_shape_ids = shape_ids_from_params(params)

    if @category.save
      update_category_listing_shapes(selected_shape_ids, @category)
      redirect_to admin_categories_path
    else
      flash[:error] = @category.errors.full_messages[0]
      redirect_to new_admin_category_path(category_type: @category_type)
      # render :action => :new, locals: { shapes: shapes, selected_shape_ids: selected_shape_ids }
    end
  end

  def edit
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @category_type = params[:category_type] ? params[:category_type] : 'category'
    shapes = @current_community.shapes
    selected_shape_ids = CategoryListingShape.where(category_id: @category.id).map(&:listing_shape_id)
    render locals: { shapes: shapes, selected_shape_ids: selected_shape_ids }
  end

  def update
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    shapes = @current_community.shapes
    selected_shape_ids = shape_ids_from_params(params)
    @category_type = @category.category_type ? @category.category_type : 'category'
    if @category.update(category_params)
      update_category_listing_shapes(selected_shape_ids, @category)
      redirect_to admin_categories_path
    else
      flash[:error] = @category.errors.full_messages[0]
      redirect_to edit_admin_category_path(id: @category.id)
      # render :action => :edit, locals: { shapes: shapes, selected_shape_ids: selected_shape_ids }
    end
  end

  def order
    category_1 = Category.find_by(sort_priority: params[:order1].to_i)
    category_2 = Category.find_by(sort_priority: params[:order2].to_i)
    category_1.update(sort_priority: params[:order2].to_i)
    category_2.update(sort_priority: params[:order1].to_i)
    respond_to do |format|
      format.html
      format.json { render json: {success: true} }
    end
  end

  # Remove form
  def remove
    @selected_left_navi_link = "listing_categories"
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @possible_merge_targets = Admin::CategoryService.merge_targets_for(@current_community.categories, @category)
  end

  # Remove action
  def destroy
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    @category.destroy
    redirect_to admin_categories_path
  end

  def destroy_and_move
    @category = @current_community.categories.find_by_url_or_id(params[:id])
    new_category = @current_community.categories.find_by_url_or_id(params[:new_category])

    if new_category
      # Move listings
      @category.own_and_subcategory_listings.update_all(:category_id => new_category.id)

      # Move custom fields
      Admin::CategoryService.move_custom_fields!(@category, new_category)
    end

    @category.destroy

    redirect_to admin_categories_path
  end

  private

  ##
  # Builds the following for category ids and corresponding priorities:
  # UPDATE categories
  #    SET sort_priority = CASE id
  #                          WHEN 1 THEN 0
  #                          WHEN 2 THEN 1
  #                            .
  #                            .
  #                            .
  #                       END
  #  WHERE id IN(1, 2, ...);
  ##
  def order_categories!(sort_priorities)
    base =  "sort_priority = CASE id\n"
    update_statements = sort_priorities.reduce(base) do |sql, (cat_id, priority)|
      sql + "WHEN #{cat_id} THEN #{priority}\n"
    end
    update_statements += "END"

    @current_community.categories.update_all(update_statements)
  end

  def update_category_listing_shapes(shape_ids, category)
    selected_shapes = @current_community.shapes.select { |s| shape_ids.include? s[:id] }

    raise ArgumentError.new("No shapes selected for category #{category.id}, shape_ids: #{shape_ids}") if selected_shapes.empty?

    CategoryListingShape.where(category_id: category.id).delete_all

    selected_shapes.each { |s|
      CategoryListingShape.create!(category_id: category.id, listing_shape_id: s[:id])
    }
  end

  def shape_ids_from_params(params)
    params[:category][:listing_shapes].map { |s_param| s_param[:listing_shape_id].to_i }
  end

  def category_params
    params.require(:category).slice(:parent_id, :translation_attributes, :sort_priority, :url, :basename, :display_title, :link).permit!
  end

end
