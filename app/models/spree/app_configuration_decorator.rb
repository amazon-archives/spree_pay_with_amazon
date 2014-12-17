##
# Amazon Payments - Login and Pay for Spree Commerce
#
# @category    Amazon
# @package     Amazon_Payments
# @copyright   Copyright (c) 2014 Amazon.com
# @license     http://opensource.org/licenses/Apache-2.0  Apache License, Version 2.0
#
##
Spree::AppConfiguration.class_eval do
  preference :amazon_checkout_display_mode, :string, :default => 'modified_checkout'
  preference :amazon_client_id, :string
  preference :amazon_merchant_id, :string
  preference :amazon_aws_access_key_id, :string
  preference :amazon_aws_secret_access_key, :string
end