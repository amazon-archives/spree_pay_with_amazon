class CreateSpreeAmazonTransactions < ActiveRecord::Migration
  def change
    create_table :spree_amazon_transactions do |t|
      t.integer :order_id
      t.string :order_reference
    end
  end
end