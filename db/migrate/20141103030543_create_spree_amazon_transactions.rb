##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
class CreateSpreeAmazonTransactions < ActiveRecord::Migration
  def change
    create_table :spree_amazon_transactions do |t|
      t.integer :order_id
      t.string :order_reference
    end
  end
end