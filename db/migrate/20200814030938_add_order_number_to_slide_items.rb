class AddOrderNumberToSlideItems < ActiveRecord::Migration[5.2]
  def change
    add_column :slide_items, :order_number, :integer

    Slideshow.all.each do |slideshow|
      i = 1
      slideshow.slide_items.each do |item|
        item.update(order_number: i)
        i += 1
      end
    end
  end
end
