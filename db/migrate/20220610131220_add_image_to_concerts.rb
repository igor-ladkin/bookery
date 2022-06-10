class AddImageToConcerts < ActiveRecord::Migration[7.0]
  include ActionView::Helpers::AssetUrlHelper

  def change
    add_column :concerts, :image_url, :string, null: false, default: image_url("unknown.jpeg")
  end
end
