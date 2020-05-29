module CategoriesHelper
  def sort_conditions
    {
      'Most Popular': 'most_popular',
      'Newest': 'newest',
      'Price: Low to High': 'price_low_first',
      'Price: High to Low': 'price_high_first'
    }
  end
end
