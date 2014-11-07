class AddAuthorizationAndCaptureCodeToTransaction < ActiveRecord::Migration
  def change
    add_column :spree_amazon_transactions, :authorization_id, :string
    add_column :spree_amazon_transactions, :capture_id, :string
  end
end
