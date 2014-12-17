##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
class AddAuthorizationAndCaptureCodeToTransaction < ActiveRecord::Migration
  def change
    add_column :spree_amazon_transactions, :authorization_id, :string
    add_column :spree_amazon_transactions, :capture_id, :string
  end
end
