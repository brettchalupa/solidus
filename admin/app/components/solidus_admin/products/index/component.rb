# frozen_string_literal: true

class SolidusAdmin::Products::Index::Component < SolidusAdmin::BaseComponent
  include SolidusAdmin::Layout::PageHelpers

  def initialize(page:)
    @page = page
  end

  def title
    Spree::Product.model_name.human.pluralize
  end

  def prev_page_path
    solidus_admin.url_for(**request.params, page: @page.number - 1, only_path: true) unless @page.first?
  end

  def next_page_path
    solidus_admin.url_for(**request.params, page: @page.next_param, only_path: true) unless @page.last?
  end

  def batch_actions
    [
      {
        display_name: t('.batch_actions.delete'),
        action: solidus_admin.products_path,
        method: :delete,
        icon: 'delete-bin-7-line',
      },
      {
        display_name: t('.batch_actions.discontinue'),
        action: solidus_admin.discontinue_products_path,
        method: :put,
        icon: 'pause-circle-line',
      },
      {
        display_name: t('.batch_actions.activate'),
        action: solidus_admin.activate_products_path,
        method: :put,
        icon: 'play-circle-line',
      },
    ]
  end

  def filters
    Spree::OptionType.all.map do |option_type|
      {
        presentation: option_type.presentation,
        combinator: 'or',
        attribute: "variants_option_values",
        predicate: "in",
        options: option_type.option_values.map do |option_value|
          [
            option_value.name,
            option_value.id
          ]
        end
      }
    end
  end

  def scopes
    [
      { name: :all, label: t('.scopes.all'), default: true },
      { name: :in_stock, label: t('.scopes.in_stock') },
      { name: :out_of_stock, label: t('.scopes.out_of_stock') },
      { name: :available, label: t('.scopes.available') },
      { name: :discontinued, label: t('.scopes.discontinued') },
      { name: :deleted, label: t('.scopes.deleted') },
    ]
  end

  def columns
    [
      image_column,
      name_column,
      status_column,
      price_column,
      stock_column,
    ]
  end

  def image_column
    {
      col: { class: "w-[72px]" },
      header: tag.span('aria-label': t('.image'), role: 'text'),
      data: ->(product) do
        image = product.gallery.images.first or return

        render(
          component('ui/thumbnail').new(
            src: image.url(:small),
            alt: product.name
          )
        )
      end
    }
  end

  def name_column
    {
      header: :name,
      data: ->(product) do
        content_tag :div, product.name
      end
    }
  end

  def status_column
    {
      header: :status,
      data: ->(product) { component('products/status').from_product(product) }
    }
  end

  def stock_column
    {
      header: :stock,
      data: ->(product) { component('products/stock').from_product(product) }
    }
  end

  def price_column
    {
      header: :price,
      data: ->(product) do
        content_tag :div, product.master.display_price.to_html
      end
    }
  end
end
