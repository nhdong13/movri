class AddOrderNumberToSections < ActiveRecord::Migration[5.2]
  def up
    add_column :sections, :order_number, :integer

    OnlineStore.all.each do |online_store|
      body_order_number = 1
      footer_order_number = 1

      online_store.sections.featured_products.each do |section|
        section.update(order_number: body_order_number)
        body_order_number += 1
      end
      online_store.sections.categories_list.each do |section|
        section.update(order_number: body_order_number)
        body_order_number += 1
      end
      online_store.sections.store_grids.each do |section|
        section.update(order_number: body_order_number)
        body_order_number += 1
      end

      online_store.sections.store_footers.each do |section|
        section.update(order_number: footer_order_number)
        footer_order_number += 1
      end

      online_store.sections.helpful_links.each do |section|
        section.update(order_number: footer_order_number)
        footer_order_number += 1
      end
    end
  end

  def down
    remove_column :sections, :order_number
  end
end
